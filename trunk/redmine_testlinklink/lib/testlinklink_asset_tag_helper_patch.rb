require_dependency "redmine/wiki_formatting/textile/helper"

module Redmine
  module WikiFormatting
    module Textile
      module Helper

        def self.included(base)
          base.class_eval do
            unloadable # Send unloadable so it will not be unloaded in development    
            alias_method_chain :heads_for_wiki_formatter, :testlinklink
          end
        end

        
        def heads_for_wiki_formatter_with_testlinklink
          heads_for_wiki_formatter_without_testlinklink
          unless @heads_for_testlinklink_included
            content_for :header_tags do
              out = stylesheet_link_tag("testcase.css", :plugin => "redmine_testlinklink")
              out += javascript_tag <<-javascript_tag
              jsToolBar.prototype.elements.testcase = {
                type: 'button',
                title: '#{l(:label_tag_testcase)}',
                fn: {
                  wiki: function() { this.encloseSelection("{{testcase(", ")}}") }
                }
              }
              javascript_tag
              out
            end
            @heads_for_testlinklink_included = true
          end
        end
        
      end
    end
  end
end
