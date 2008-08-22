require 'pathname'

__DIR__ = Pathname.new(__FILE__).dirname
$LOAD_PATH << __DIR__ unless $LOAD_PATH.include?(__DIR__)

Lucky7Root= (__DIR__ + "..").expand_path

require 'rubygems'
require 'facets'
require 'basis'
require 'johnson'
require 'sequel'
require 'vendor/sinatra/lib/sinatra'
require 'lib/lucky7'
require 'fold'
require 'jabs'
require 'jass'
require 'haml'
require 'sass'
