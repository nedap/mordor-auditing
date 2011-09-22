require File.join(File.dirname(__FILE__), '..', '/spec_helper.rb')

module ConnectionSpecHelper
  def clean_sheet
    @connection ||= Mongo::Connection.new(CONFIG[:hostname], CONFIG[:port])
    db = @connection[CONFIG[:database]]
    [Auditing::Request, Auditing::Modification].each do |klass|
      db[klass.collection_name].drop
    end
  end
end

describe "connecting to mongo" do
  include ConnectionSpecHelper

  before :each do
    clean_sheet
  end

  it "should have a connection to mongo" do
    
  end
end
