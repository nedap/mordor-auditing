require 'rubygems'
require 'mongo'

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'auditing'

CONFIG = {
  :hostname => 'localhost',
  :port     =>  27017,
  :database => 'test'
}
