class Article
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
    @url = "/articles/#{date_string}-#{title_string}"
    @content = File.open(filename).read
  end

  def self.articles_dir
    File.join(File.dirname(__FILE__), '../articles/')
  end
  
  def self.find_all
    Dir.glob(articles_dir + '*.*').collect { |f| Article.new(f) }.sort { |a,b| b.date <=> a.date }
  end
  
  def self.find_by_title(title)
    Article.new(articles_dir + title + '.haml')
  end
end