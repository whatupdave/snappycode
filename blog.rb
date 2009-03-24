require 'rubygems'
require 'sinatra'
require 'bluecloth'

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
    posts = []
    Dir.glob(posts_dir + '*.*') do |f|
      posts << Post.new(f)
    end
    posts
  end
  
  def self.find_by_title(title)
    Post.new(posts_dir + title + '.markdown')
  end
  
  def html
    BlueCloth.new(@content).to_html
  end
end

helpers do
  def write_post_content(post)
    post.html
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

get '/posts/:post' do
  @post = Post.find_by_title(params[:post])
  haml :show
end

get '/rss.xml' do
  @posts = Post.find_all
  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title ":snappyco.de => Dave Newman"
        xml.description "Dave's blog of snappy cool"
        xml.link "http://snappyco.de/rss.xml"
        
        @posts.each do |post|
          xml.item do
            xml.title post.title
            xml.link "http://snappyco.de#{post.url}"
            xml.description post.html
            xml.pubDate Time.parse(post.date.to_s).rfc822()
            xml.guid "http://snappyco.de#{post.url}"
          end
        end
      end
    end
  end
end