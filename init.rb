ENV['TZ'] = 'Australia/Sydney'
 
# Declare gems via the .gems file
File.file?(gems_file = "#{File.dirname(__FILE__)}/.gems") && File.read(gems_file).each do |gem_decl|
  gem_name, version = gem_decl[/^([^\s]+)/,1], gem_decl[/--version ([^\s]+)/,1]
  version ? gem(gem_name, version) : gem(gem_name)
end
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