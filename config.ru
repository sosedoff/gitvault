#!/usr/bin/env ruby
$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')

require 'logger'
require 'gitvault/server'

run Gitvault::Server.new