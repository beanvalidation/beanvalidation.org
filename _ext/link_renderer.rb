##
#
# An extension which renders the pager using the Semantic UI pagination styles. Requires the default
# pagination extension to be enabled.
#
##
module InRelationTo
  module Extensions
    class PaginationLinkRenderer

      module SemanticUiPaginationLinkRenderer

        def semantic_ui_pager_links
          html = %Q(<div class="ui menu pagination">)
          if !previous_page.nil?
            html += %Q(<a class="item" href="#{previous_page.url}">&laquo;</a>)
          else
            html += %Q(<a class="disabled item" href="#">&laquo;</a>)
          end
          first_skip = false
          second_skip = false
          pages.each_with_index do |page, i|
            if ( i == current_page_index )
              html += %Q(<a class="active item" href="#">#{i+1}</a> )
            elsif ( i <= window )
              html += %Q(<a class="item" href="#{page.url}">#{i+1}</a> )
            elsif ( ( i > window ) && ( i < ( current_page_index - window ) ) && ! first_skip  )
              html += %Q(<a class="disabled item"><a href="#">...</a>)
              first_skip = true
            elsif ( ( i > ( current_page_index + window ) ) && ( i < ( ( pages.size - window ) - 1 ) ) && ! second_skip )
              html += %Q(<a class="item" href="#">...</a>)
              second_skip = true
            elsif ( ( i >= ( current_page_index - window ) ) && ( i <= ( current_page_index + window ) ) )
              html += %Q(<a class="item" href="#{page.url}">#{i+1}</a> )
            elsif ( i >= ( ( pages.size - window ) - 1 ) )
              html += %Q(<a class="item" href="#{page.url}">#{i+1}</a> )
            end
          end
          if !next_page.nil?
            html += %Q(<a class="item" href="#{next_page.url}">&raquo;</a> )
          else
            html += %Q(<a class="disabled item" href="#">&raquo;</a> )
          end
          html += %Q(</div>)
          html
        end
      end

      def execute(site)
        site.pages.each do |page|
          page.posts.extend( SemanticUiPaginationLinkRenderer )
        end
      end

    end
  end
end
