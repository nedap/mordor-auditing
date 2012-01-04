require 'rubygems'
require 'mongo'
require 'mordor'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'auditing'

Mordor::Config.use do |config|
 config[:database] = 'test'
end

def clean_sheet
  @connection = Mongo::Connection.new(Mordor::Config[:hostname], Mordor::Config[:port])
  @db = @connection[Mordor::Config[:database]]
  [Auditing::Request, Auditing::Modification].each do |klass|
    @db[klass.collection_name].drop
  end
end
