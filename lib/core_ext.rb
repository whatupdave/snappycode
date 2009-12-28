class String
  def linkify
    gsub(/(http[^ ]*)/) { "<a href=\"#{$1}\">#{$1}</a>" }
  end
  
  def link_mentions
    gsub(/@([^ ]*)/){ "@<a class=\"mention\" href=\"http://twitter.com/#{$1}\">#{$1}</a>" }
  end

  def link_hash_tags
    gsub(/#([^ ]*)/){ "<a class=\"hash_tag\" href=\"http://twitter.com/#search?q=%23#{$1}\">##{$1}</a>" }
  end
end