require 'rubygems'
require 'mongo'
require 'mordor'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'auditing'

module Mordor
CONFIG = {
  :hostname => 'localhost',
  :port     =>  27017,
  :database => 'test'
}
end

def clean_sheet
  @connection ||= Mongo::Connection.new(Mordor::CONFIG[:hostname], Mordor::CONFIG[:port])
  @db ||= @connection[Mordor::CONFIG[:database]]
  [Auditing::Request, Auditing::Modification].each do |klass|
    @db[klass.collection_name].drop
  end
end

