require 'rubygems'
require 'mongo'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'auditing'

module Auditing
CONFIG = {
  :hostname => 'localhost',
  :port     =>  27017,
  :database => 'test'
}
end

def clean_sheet
  @connection ||= Mongo::Connection.new(Auditing::CONFIG[:hostname], Auditing::CONFIG[:port])
  @db ||= @connection[Auditing::CONFIG[:database]]
  [Auditing::Request, Auditing::Modification].each do |klass|
    @db[klass.collection_name].drop
  end
  if Object.const_defined?('TestResource')
    @db[TestResource.collection_name].drop
  end
end

