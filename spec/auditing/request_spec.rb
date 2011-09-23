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

  def compare_modifications(stored_mods, retrieved_mods)
    if retrieved_mods.is_a?(BSON::OrderedHash)
      retrieved_mods['_id'].should == stored_mods._id
      retrieved_mods['request_id'].should == (stored_mods.request_id ? stored_mods.request_id : "")
      retrieved_mods['object_type'].should == stored_mods.object_type
      retrieved_mods['object_id'].should == stored_mods.object_id
      retrieved_mods['changes'].size.should == stored_mods.changes.size
      retrieved_mods['changes'].each do |k,v|
        stored_mods.changes[k].should == v
      end
      retrieved_mods['action'].should == stored_mods.action
      retrieved_mods['at'].to_s.should == stored_mods.at.to_time.to_s
    else
      retrieved_mods._id.should == stored_mods._id
      retrieved_mods.request_id.should == (stored_mods.request_id ? stored_mods.request_id : "")
      retrieved_mods.object_type.should == stored_mods.object_type
      retrieved_mods.object_id.should == stored_mods.object_id
      retrieved_mods.changes.each do |key, value|
        stored_mods.changes[key].should == value
      end
      retrieved_mods.action.should == stored_mods.action
      retrieved_mods.at.to_s.to_should == stored_mods.at.to_time.to_s
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
      if value.is_a?(Hash)
        value.each do |k, v|
          ret_val[k.to_s].should == v
        end
      else
        ret_val.should == value
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

    describe "with respect to modifications" do
      before :each do
        options = {
          :request_id => @request._id,
          :object_type => "Audited::Request",
          :object_id => @request._id.to_s,
          :changes => {:url => [@request.url, "#{@request.url}/request"]},
          :action => 'get',
          :at => @request.at,
          :request_id => @request._id
        }
        @modification = Auditing::Modification.new(options)
        @modification.save.should be_true
        @modification._id.should_not be_nil
        Auditing::Modification.collection.count == 1
      end

      it "should correctly retrieve the corresponding modifications" do
        @request.modifications.should_not be_nil
        @request.modifications.size.should == 1
        compare_modifications(@modification, @request.modifications.first)
      end
    end
  end
end
