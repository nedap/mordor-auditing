require 'rubygems'
require 'mongo'
require 'mordor'
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')

Mordor::Config.use do |config|
  config[:username] = nil
  config[:password] = nil
  config[:hostname] = '127.0.0.1'
  config[:port] = 27017
  config[:database] = 'test'
end

require 'auditing'


def clean_sheet
  @connection = Mongo::Connection.new(Mordor::Config[:hostname], Mordor::Config[:port])
  @db = @connection[Mordor::Config[:database]]
  [Auditing::Request, Auditing::Modification].each do |klass|
    @db[klass.collection_name].remove
    @db[klass.collection_name].drop
  end
end
