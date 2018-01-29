require 'mytagger'
require 'relative'
require 'sassc'
require 'link_renderer'
require 'redirect_creator'

# hack to add asciidoc support in HAML
# remove once haml_contrib has accepted the asciidoc registration patch
# :asciidoc
#   some block content
#
# :asciidoc
#   :doctype: inline
#   some inline content
#
if !Haml::Filters.constants.map(&:to_s).include?('AsciiDoc')
  Haml::Filters.register_tilt_filter 'AsciiDoc'
  Haml::Filters::AsciiDoc.options[:safe] = :safe
  Haml::Filters::AsciiDoc.options[:attributes] ||= {}
  Haml::Filters::AsciiDoc.options[:attributes]['notitle!'] = ''
  # copy attributes from site.yml
  attributes = site.asciidoctor[:attributes].each do |key, value|
  Haml::Filters::AsciiDoc.options[:attributes][key] = value
  end
end

Awestruct::Extensions::Pipeline.new do
  extension Awestruct::Extensions::Posts.new( '/news', :posts )
  extension Awestruct::Extensions::Paginator.new(:posts, '/news/index', :per_page => 5 )
  extension Awestruct::Extensions::MyTagger.new( :posts,
                                               '/news/index',
                                               '/news/tags',
                                               :per_page=>5 )
  extension InRelationTo::Extensions::PaginationLinkRenderer.new()
  extension Awestruct::Extensions::Indexifier.new
  extension Awestruct::Extensions::Atomizer.new( :posts, '/news/news.atom' )
  extension Awestruct::Extensions::Disqus.new
  extension Awestruct::Extensions::RedirectCreator.new "redirects"

  helper Awestruct::Extensions::Partial
  helper Awestruct::Extensions::Relative
  helper Awestruct::Extensions::GoogleAnalytics
end
