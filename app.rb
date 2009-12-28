require 'init'

helpers do
  def partial(name, locals={})
    haml "_#{name}".to_sym, :layout => false, :locals => locals
  end
    
  def transform_ampersands(html)
    html.gsub(' & '," <span class='amp'>&</span> ")
  end

  def render_article(article)
    haml(transform_ampersands(article.content), :layout => false)
  end  
  
  def tweets_html
    File.join(File.dirname(__FILE__), 'tmp/cache', 'tweets.html') 
  end

  def github_repos_html
    File.join(File.dirname(__FILE__), 'tmp/cache', 'github_repos.html') 
  end
  
  def tweets
    File.read(tweets_html)
  end
    
  def format_tweet(text)
    text.linkify.link_mentions.link_hash_tags
  end
  
  def github_repos
    File.read(github_repos_html)
  end
  
  def obscure_email(email)
    lower = ('a'..'z').to_a
    upper = ('A'..'Z').to_a
    email.split('').map { |char|
      output = lower.index(char) + 97 if lower.include?(char)
      output = upper.index(char) + 65 if upper.include?(char)
      output ? "&##{output};" : (char == '@' ? '&#0064;' : char)
    }.join
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
    begin
      text = yield
    rescue
     text = "Service unavailable"
    end
    
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, 'w') { |f| f.write( text ) }
  end
end

before do
  def get_non_reply_tweets
    Twitter::Search.new.from("whatupdave").fetch().results.reject { |tweet| tweet.text[0] == 64 } .first(5)
  end
  
  cache(:file => tweets_html, :expiry => 30) do
    @tweets = get_non_reply_tweets
    text = haml :tweets, :layout => false
    text
  end
  cache(:file => github_repos_html, :expiry => 30) do
    url = 'http://github.com/api/v1/json/snappycode'
    @github_data = JSON.load(Net::HTTP.get_response(URI.parse(url)).body)
    text = haml :github_repos, :layout => false
    text
  end
end

get /^(.+)\.css$/ do |style_file|
  sass_file = File.join('public','css',"#{style_file}.sass")
  pass unless File.exist?(sass_file)
  content_type :css
  etag File.mtime(sass_file)
  sass File.read(sass_file)
end

get '/' do
  @articles = Article.find_all
  view :index, :layout => :layout
end

get '/rss.xml' do
  @articles = Article.find_all
  content_type 'application/rss+xml'
  haml :rss, :layout => false
end

get '/articles/:article' do
  @article = Article.find_by_title(params[:article])
  haml :show
end

get '/tags/:tag' do
  @articles = Article.find_by_tag(params[:tag])
  haml :index
end

# backwards compatibility
get '/posts/:post' do
  @article = Article.find_by_title(params[:post])
  haml :show
end

