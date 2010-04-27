ENV['TZ'] = 'Australia/Sydney'

require "rubygems"
require "bundler"
Bundler.setup

require 'sinatra'
require 'haml'
require 'sass'
require 'rdiscount'
require 'sinatra/fancyviews'
require 'twitter'
require 'fileutils' 
require 'net/http'
require 'json'
require 'lib/article.rb'
require 'lib/core_ext.rb'

require 'sass/plugin'
Sass::Plugin.options[:load_paths] = [Sinatra::Application.views]
 
set :app_file => 'app.rb'