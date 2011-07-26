require 'mytagger'

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::Posts.new( '/news', :posts )
  extension Awestruct::Extensions::Paginator.new(:posts, '/news/index', :per_page => 5 )
  extension Awestruct::Extensions::MyTagger.new( :posts, 
                                               '/news/index', 
                                               '/news/tags', 
                                               :per_page=>5 )
  extension Awestruct::Extensions::Atomizer.new( :posts, '/news/news.atom' )
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Disqus.new
  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::GoogleAnalytics
end

