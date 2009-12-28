class Article
  attr_reader :url
  attr_reader :date
  attr_reader :title
  attr_reader :content

  def self.articles_dir
    File.join(File.dirname(__FILE__), '../articles/')
  end
  
  def self.article_files
    Dir.glob(articles_dir + '*.*')
  end
  
  def self.all_articles
    article_files.collect { |f| Article.new(f) }
  end
  
  def self.find_all
    all_articles.sort { |a,b| b.date <=> a.date }
  end
  
  def self.find_by_title(title)
    Article.new(articles_dir + title + '.haml')
  end
  
  def self.find_by_tag(tag)
    all_articles.select { |a| a.tags.include?(tag) }.sort { |a,b| b.date <=> a.date }
  end
  
  def initialize(filename)
    /(\d{4}-\d{2}-\d{2})-([^\.]*)\.(.*)/.match filename
    date_string = $1
    title_string = $2
    @content = File.open(filename).read
    @date = Date.parse(date_string)
    @title = slot('title') || title_string.gsub('-',' ')
    @url = "/articles/#{date_string}-#{title_string}"
    @mtime = File.mtime(filename)
  end

  def tags
    (slot('tags') || '').split(' ')
  end
  
  def etag
    @mtime
  end

  def slot(name)
    @content[/^-#\s+#{name}:\s*(.*)$/, 1].try(:strip)
  end
end