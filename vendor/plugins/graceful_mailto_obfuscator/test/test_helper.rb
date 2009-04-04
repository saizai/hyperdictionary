test_root = File.dirname(__FILE__)
plugin_root = File.join test_root, ".."
lib_root = File.join plugin_root, "lib"

require 'rubygems'
require 'test/spec'

require 'actionpack'
require 'action_controller'
require 'action_controller/cgi_ext'
require 'action_controller/test_process'

$:.unshift lib_root

require File.join plugin_root, "init"