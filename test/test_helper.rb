require 'rubygems'
require 'test/unit'
begin
  require 'redgreen'
  require 'turn'
rescue LoadError
end
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
