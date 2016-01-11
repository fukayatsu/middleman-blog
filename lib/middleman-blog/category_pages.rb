require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap resource manipulator that adds a tag page to the sitemap
    # for each tag in the associated blog
    class CategoryPages
      include UriTemplates

      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_controller = blog_controller
        @category_link_template = uri_template blog_controller.options.categorylink
        @category_template = blog_controller.options.category_template
        @blog_data = blog_controller.data
      end

      # Get a path to the given category, based on the :categorylink setting.
      # @param [String] category
      # @return [String]
      def link(category)
        apply_uri_template @category_link_template, category: category
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources + @blog_data.categories.map do |category, articles|
          category_page_resource(category, articles)
        end
      end

      private

      def category_page_resource(category, articles)
        Sitemap::ProxyResource.new(@sitemap, link(category), @category_template).tap do |p|
          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'category',
            'categoryname' => category,
            'articles' => articles,
            'blog_controller' => @blog_controller
          }
        end
      end
    end
  end
end