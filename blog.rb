require 'rubygems'
require 'sinatra'
require 'bluecloth'

posts_dir = File.dirname(__FILE__) + '/posts/'

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
end

helpers do
  def write_post_content(post)
    BlueCloth.new(post.content).to_html
  end
end

get '/screen.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :screen
end

get '/' do
  @posts = []
  Dir.glob(posts_dir + '*.*') do |f|
    @posts << Post.new(f)
  end
  
  haml :index
end

get '/posts/:post' do
  @post = Post.new(posts_dir + params[:post] + '.markdown')
  haml :show
end