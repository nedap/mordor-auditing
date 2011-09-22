require File.join(File.dirname(__FILE__), '..', '/spec_helper.rb')

module AuditingRequestSpecHelper
  def compare_requests(stored_request, retrieved_request)
    if retrieved_request.is_a?(BSON::OrderedHash)
      retrieved_request['url'].should                                      == stored_request.url
      retrieved_request['method'].should                                   == stored_request.method
      retrieved_request['params'].should be_instance_of(BSON::OrderedHash)
      retrieved_request['params'].should have_key("test_param1")
      retrieved_request['params']['test_param1'].should                    == stored_request.params['test_param1']
      retrieved_request['params'].should have_key("test_param2")
      retrieved_request['params']['test_param2'].should                    == stored_request.params['test_param2']
      retrieved_request['user_id'].should                                  == stored_request.user_id
      retrieved_request['real_user_id'].should                             == stored_request.real_user_id
      retrieved_request['at'].to_s.should                                  == stored_request.at.gmtime.to_s
    else
      retrieved_request.url == stored_request.url
      retrieved_request.method == stored_request.method
      retrieved_request.user_id == stored_request.user_id
      retrieved_request.real_user_id == stored_request.real_user_id
      retrieved_request.at == stored_request.at
    end
  end
end

describe "with respect to auditing requests" do
  include AuditingRequestSpecHelper

  before :each do
    clean_sheet
  end

  it "should correctly initialize" do
    options = {
      :url => 'http://test.com',
      :method => 'get',
      :params => {:test_param1 => '1', :test_param2 => '2'},
      :user_id => 3,
      :real_user_id => 5,
      :at => Time.now
    }

    request = Auditing::Request.new(options)
    options.each do |key, value|
      ret_val = request.send(key)
      if value.is_a?(Array)
        value.each do |k, v|
          ret_val[k] == value[k]
        end
      else
        ret_val == value
      end
    end
  end

  it "should correctly replace Date params with Times" do
    options = {
      :params => {:first => Date.today}
    }
    request = Auditing::Request.new(options)
    request.params["first"].should be_instance_of(Time)
  end

  it "should correctly replace DateTime params with Time's" do
    options = {
      :params => {:first => DateTime.now}
    }
    request = Auditing::Request.new(options)
    request.params["first"].should be_instance_of(Time)
  end

  context "with respect to saving" do
    it "should correctly save the request" do
      options = {
        :url => 'http://test.com',
        :method => 'get',
        :params => {:test_param1 => '1', :test_param2 => '2'},
        :user_id => 3,
        :real_user_id => 5,
        :at => Time.now
      }
      request = Auditing::Request.new(options)
      request.save.should be_true
      request._id.should_not be_nil

      Auditing::Request.collection.count.should == 1

      other_request = request.class.collection.find_one(:_id => request._id)

      compare_requests(request, other_request)
    end
  end

  describe "with respect to retrieval" do
    before(:each) do
      options = {
        :url => 'http://test.com',
        :method => 'get',
        :params => {:test_param1 => '1', :test_param2 => '2'},
        :user_id => 3,
        :real_user_id => 5,
        :at => Time.now
      }
      @request = Auditing::Request.new(options)
      @request.save.should be_true
      Auditing::Request.collection.find(:_id => @request._id).count.should == 1
    end

    it "should correctly retrieve a request by its _id" do
      req = Auditing::Request.find_by_id(@request._id)
      compare_requests(@request, req)
    end

    it "should correctly retrieve requests on a certain day" do
      reqs = Auditing::Request.find_by_day(Date.today)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)

      reqs = Auditing::Request.find_by_day(DateTime.now)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end

    it "should correctly retrieve requests by url" do
      reqs = Auditing::Request.find_by_url(@request.url)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end

    it "should correctly retrieve requests by part of an url" do
      reqs = Auditing::Request.find_by_url(@request.url[0, @request.url.length - 2], true)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end

    it "should correctly retrieve requests by user_id" do
      reqs = Auditing::Request.find_by_user(@request.user_id)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end

    it "should correctly retrieve requests by real_user_id" do
      reqs = Auditing::Request.find_by_real_user_id(@request.real_user_id)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end

    it "should correctly retrieve requests by method" do
      reqs = Auditing::Request.find_by_method(@request.method)
      reqs.size.should == 1
      compare_requests(@request, reqs.first)
    end
  end
end
