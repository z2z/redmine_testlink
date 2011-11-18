module ActionView
  module Helpers
    module AssetTagHelper
      def javascript_include_tag_with_testlinklink(*sources)
        out = javascript_include_tag_without_testlinklink(*sources)
        if sources.is_a?(Array) and sources[0] == 'jstoolbar/textile'
          out += javascript_tag <<-javascript_tag
jsToolBar.prototype.elements.testcase = {
	type: 'button',
        title: '#{l(:label_tag_testcase)}',
	fn: {
		wiki: function() { this.encloseSelection("{{testcase(", ")}}") }
	}
}
javascript_tag
          out += stylesheet_link_tag 'testcase', :plugin => 'redmine_testlinklink'
        end
        out
      end
      alias_method_chain :javascript_include_tag, :testlinklink
    end
  end
end
