require 'rubygems'
require 'sinatra'
require 'bluecloth'
require 'twitter'
require 'fileutils' 

class Post
  attr_reader :url
  attr_reader :date
  attr_reader :title
  attr_reader :content
  attr_reader :format
  
  def initialize(filename)
    /(\d{4}-\d{2}-\d{2})-([^\.]*)\.(.*)/.match filename
    date_string = $1
    title_string = $2
    @format = $3
    @date = Date.parse(date_string)
    @title = title_string.gsub('-',' ')
    @url = "/posts/#{date_string}-#{title_string}"
    @content = File.open(filename).read
  end

  def self.posts_dir
    File.dirname(__FILE__) + '/posts/'
  end
  
  def self.find_all
    Dir.glob(posts_dir + '*.*').collect { |f| Post.new(f) }.sort { |a,b| b.date <=> a.date }
  end
  
  def self.find_by_title(title)
    Post.new(posts_dir + title + '.markdown')
  end
  
  def html
    BlueCloth.new(@content).to_html
  end
end

def tweets_html
  File.join(File.dirname(__FILE__), 'tmp/cache', 'tweets.html') 
end

class String
  def linkify
    gsub (/(http[^ ]*)/) { "<a href=\"#{$1}\">#{$1}</a>" }
  end
  
  def link_mentions
    gsub(/@([^ ]*)/){ "@<a href=\"http://twitter.com/#{$1}\">#{$1}</a>" }
  end

  def link_hash_tags
    gsub(/#([^ ]*)/){ "#<a href=\"http://twitter.com/#search?q=%23#{$1}\">#{$1}</a>" }
  end
end

helpers do
  def write_post_content(post)
    post.html
  end
  
  def tweets
    File.read(tweets_html)
  end
    
  def format_tweet(text)
    text.linkify.link_mentions.link_hash_tags
  end
end

def cache(options = {}, &block)
  path = options[:file]
  
  if File.exists? path
    cache_mins = (Time.now - File.mtime(path)) / 60
  else
    cache_mins = 999999999999
  end

  if cache_mins > options[:expiry]
    text = yield
    
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write( text ) }
  end
  
end

before do
  cache(:file => tweets_html, :expiry => 30) do
    puts 'refreshing tweets'
    @tweets = Twitter::Search.new.from('whatupdave').fetch().results
    text = haml :tweets, :layout => false
    text
  end
end

get '/screen.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :screen
end

get '/' do
  @posts = Post.find_all
  haml :index
end

get '/rss.xml' do
  @posts = Post.find_all
  haml :rss, :layout => false
end

get '/posts/:post' do
  @post = Post.find_by_title(params[:post])
  haml :show
end

