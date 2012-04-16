require 'erubis'
require 'pathname'
require 'double_doc/html_renderer'
require 'fileutils'

module DoubleDoc
  class HtmlGenerator
    DEFAULT_CSS = File.expand_path("../../templates/screen.css", File.dirname(__FILE__)).freeze

    def initialize(sources, options)
      @sources = sources
      @template_file = options[:html_template] || File.expand_path("../../templates/default.html.erb", File.dirname(__FILE__))
      @output_directory = Pathname.new(options[:html_destination])
      @html_renderer = options[:html_renderer] || HtmlRenderer
      @stylesheet = options[:html_css] || DEFAULT_CSS
      @title = options[:title] || 'Documentation'
      @exclude_from_navigation = options[:exclude_from_navigation] || []
    end

    def generate
      FileUtils.mkdir_p(@output_directory)

      copy_assets
      generated_files = [@output_directory + File.basename(@stylesheet)]

      @sources.each do |src|
        from_markdown = src.to_s =~ /\.md$/
        if from_markdown
          path = File.basename(src).sub(/\.md$/, '.html')
        else
          path = File.basename(src)
        end

        dst = @output_directory + path
        puts "#{src} -> #{dst}"
        FileUtils.mkdir_p(File.dirname(dst))

        if from_markdown
          markdown = self.class.convert_links_to_html!(File.new(src).read)
          body = @html_renderer.render(markdown)
        else
          body = File.new(src).read
        end

        File.open(dst, 'w') do |out|

          html = template.result(
            :title         => @title,
            :body          => body,
            :css           => File.basename(@stylesheet),
            :sitemap       => sitemap,
            :path          => path
          )
          out.write(html)
        end
        generated_files << dst
      end

    end

    def sitemap
      return @sitemap unless @sitemap.nil?

      @sitemap = []

      navigation_sources = @sources - @exclude_from_navigation

      navigation_sources.each do |src|
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
      if @stylesheet
        FileUtils.cp(@stylesheet, @output_directory)
      end
    end

    def template
      @template ||= Erubis::Eruby.new(File.read(@template_file))
    end

    def self.convert_links_to_html!(markdown)
      markdown.gsub!(/(\[[^\]]+\]\([^\)]+)\.md([^\)]*)\)/) do |match|
        $1 + '.html' + $2 + ')'
      end
      markdown
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
