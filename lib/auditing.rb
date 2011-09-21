require 'mongo'
require 'auditing/version'
require 'auditing/collection'
require 'auditing/resource'
require 'auditing/request'
require 'auditing/modifications'

module Auditing

  CONFIG = {
    :hostname => 'localhost',
    :port     => 27017,
    :database => 'development'
  }

  def connection
    @connection ||= Mongo::Connection.new(CONFIG[:hostname], CONFIG[:port])
    @connection.autenticate(CONFIG[:username], CONFIG[:password]) if CONFIG[:username]
    @connection.db(CONFIG[:database])
  end
  module_function :connection

end
