require File.join(File.dirname(__FILE__), '..', '/spec_helper.rb')

module AuditingModificationSpecHelper
  def compare_modifications(stored_mods, retrieved_mods)
    if retrieved_mods.is_a?(BSON::OrderedHash)
      retrieved_mods['_id'].should == stored_mods._id
      retrieved_mods['request_id'].should == (stored_mods.request_id ? stored_mods.request_id : nil)
      retrieved_mods['object_type'].should == stored_mods.object_type
      retrieved_mods['object_id'].should == stored_mods.object_id
      retrieved_mods['changes'].size.should == stored_mods.changes.size
      retrieved_mods['changes'].each do |k,v|
        stored_mods.changes[k].should == v
      end
      retrieved_mods['action'].should == stored_mods.action
      retrieved_mods['at'].should == stored_mods.at.to_time
    else
      retrieved_mods._id.should == stored_mods._id
      retrieved_mods.request_id.should == (stored_mods.request_id ? stored_mods.request_id : nil)
      retrieved_mods.object_type.should == stored_mods.object_type
      retrieved_mods.object_id.should == stored_mods.object_id
      retrieved_mods.changes.each do |key, value|
        stored_mods.changes[key].should == value
      end
      retrieved_mods.action.should == stored_mods.action
      retrieved_mods.at.should == stored_mods.at.to_time
    end
  end
end

describe "with respect to modifications" do
  include AuditingModificationSpecHelper

  before :each do
    clean_sheet
  end

  it "should correctly initialize" do
    options = {
      :object_type => 'String',
      :object_id => 2,
      :changes => {:length => [2, 4]},
      :action => 'put',
      :at => DateTime.now.to_time
    }
    mod = Auditing::Modification.new(options)
    options.each do |key, value|
      ret_val = mod.send(key)
      if value.is_a?(Hash)
        value.each do |k, v|
          ret_val[k.to_s].should == v
        end
      else
        ret_val.should == value
      end
    end
  end

  it "should have a timestamp attribute" do
    Auditing::Request.timestamped_attribute.should_not be_nil
  end

  it "should add a timestamp value after creation" do
    options = {
        :object_type => 'String',
        :object_id => 2,
        :changes => {:length => [2, 4]},
        :action => 'put',
        :at => DateTime.now.to_time
      }

    mod = Auditing::Modification.create(options)
    mod.reload
    mod.timestamp.should_not be_nil
    mod.timestamp.should_not == BSON::Timestamp.new(0,0)
  end

  context "with respect to saving and retrieving" do
    it "should correctly save the modification" do
      options = {
        :object_type => 'String',
        :object_id => 2,
        :changes => {:length => [2, 4]},
        :action => 'put',
        :at => DateTime.now.to_time
      }

      mod = Auditing::Modification.new(options)
      mod.save.should be_true
      mod._id.should_not be_nil

      Auditing::Modification.collection.count.should == 1

      other_mod = mod.class.collection.find_one(:_id => mod._id)

      compare_modifications(mod, other_mod)
    end
  end

  describe "with respect to retrieval" do
    before :each do
      options = {
        :object_type => 'String',
        :object_id => 2,
        :changes => {:length => [2, 4]},
        :action => 'put',
        :at => DateTime.now.to_time
      }

      @modification = Auditing::Modification.new(options)
      @modification.save.should be_true
      @modification._id.should_not be_nil
    end

    it "should correctly retrieve saved modifications by its _id" do
      mod = Auditing::Modification.find_by_id(@modification._id)
      compare_modifications(@modification, mod)
    end

     it "should correctly retrieve requests on a certain day" do
      mods = Auditing::Modification.find_by_day(Date.today)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)

      mods = Auditing::Modification.find_by_day(DateTime.now)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

    it "should correctly retrieve requests by object_type" do
      mods = Auditing::Modification.find_by_object_type(@modification.object_type)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

    it "should correctly retrieve requests by object_id" do
      mods = Auditing::Modification.find_by_object_id(@modification.object_id)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

    it "should correctly retrieve requests by action" do
      mods = Auditing::Modification.find_by_action(@modification.action)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

    it "should correctly retrieve requests by request_id" do
      @modification.request_id = "4e79b0b20e02e145a9000001"
      @modification.save.should be_true
      mods = Auditing::Modification.find_by_request_id(@modification.request_id)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

    it "should correctly retrieve requests by request" do
      @modification.request_id = "4e79b0b20e02e145a9000001"
      @modification.save.should be_true
      mods = Auditing::Modification.find_by_request(@modification.request_id)
      mods.size.should == 1
      compare_modifications(@modification, mods.first)
    end

  end
end
