require 'erubis'
require 'pathname'
require 'double_doc/html_renderer'
require 'fileutils'

module DoubleDoc
  class HtmlGenerator
    def initialize(sources, options)
      @sources = sources
      @template_file = options[:html_template] || File.expand_path("../../templates/default.html.erb", File.dirname(__FILE__))
      @output_directory = Pathname.new(options[:html_destination])
      @html_renderer = options[:html_renderer] || HtmlRenderer
      @stylesheet = options[:html_css] || 'screen.css'
      @title = options[:title] || 'Documentation'
    end

    def generate
      copy_assets

      @sources.each do |src|
        dst = @output_directory + File.basename(src).sub(/\.md$/, '.html')
        puts "#{src} -> #{dst}"
        FileUtils.mkdir_p(File.dirname(dst))
        File.open(dst, 'w') do |out|
          markdown = File.new(src).read
          body = @html_renderer.render(markdown)
          html = template.result(
            :title         => @title,
            :body          => body,
            :css           => @stylesheet,
            :sitemap       => sitemap
          )
          out.write(html)
        end
      end
    end

    def sitemap
      return @sitemap unless @sitemap.nil?

      @sitemap = []

      @sources.each do |src|
        path = File.basename(src).sub(/\.md$/, '.html')
        lines = File.readlines(src)

        item = nil
        lines.each do |line|
          if line =~ /^\#\#\s/
            title = line.sub(/^\#+\s*/, '').strip
            @sitemap << item if item
            item = SitemapItem.new(title, path)
          elsif line =~ /^\#\#\#\s/
            item ||= SitemapItem.new(path, path)
            title = line.sub(/^\#+\s*/, '').strip
            item.add_child(SitemapItem.new(title, path, DoubleDoc::HtmlRenderer.generate_id(title)))
          end
        end

        @sitemap << item if item
      end

      @sitemap
    end

    def copy_assets
      if @stylesheet == 'screen.css'
        FileUtils.cp(File.expand_path("../../templates/screen.css", File.dirname(__FILE__)), @output_directory)
      end
    end

    def template
      @template ||= Erubis::Eruby.new(File.read(@template_file))
    end

    class SitemapItem
      attr_reader :title, :path, :id, :children
      attr_accessor :parent

      def initialize(title, path, id = nil)
        @title    = title
        @path     = path
        @id       = id
        @children = []
      end

      def add_child(child)
        child.parent = self
        children << child
        child
      end

      def href
        if id
          "#{path}##{id}"
        else
          path
        end
      end
    end
  end

end
