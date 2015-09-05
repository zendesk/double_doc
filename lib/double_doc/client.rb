require 'double_doc/import_handler'
require 'double_doc/html_generator'

module DoubleDoc
  class Client
    attr_reader :md_sources, :options

    def initialize(md_sources, options = {})
      @md_sources = [md_sources].flatten
      @options = options
    end

    def process
      sources = md_sources.map do |source|
        if source.to_s =~ /\*/
          import_handler.load_paths.map do |path|
            Dir.glob(File.join(path, source))
          end
        else
          import_handler.find_file(source).path
        end
      end.flatten.uniq

      generated_md_files = []

      md_dst = Pathname.new(options[:md_destination])
      system('mkdir', '-p', md_dst.to_s)
      sources.each do |src|
        next if File.directory?(src)
        dst = md_dst + File.basename(src)
        puts "#{src} -> #{dst}" unless options[:quiet]

        if src.to_s =~ /\.md$/
          body = import_handler.resolve_imports(File.new(src))
        else
          body = File.read(src)
        end

        File.open(dst, 'w') do |out|
          out.write(body)
        end

        generated_md_files << dst
      end

      args = options[:args] || {}
      html_dst = Pathname.new(options[:html_destination]) if options[:html_destination]
      if html_dst || args[:html_destination]
        html_generator = DoubleDoc::HtmlGenerator.new(generated_md_files, options.merge(args))
        html_generator.generate
      end

      sources
    end

    private

    def import_handler
      return @import_handler if defined?(@import_handler)

      roots = options[:roots] || [File.dirname(__FILE__)]
      import_options = options.fetch(:import, {})
      roots << { :quiet => options[:quiet] }.merge(import_options)
      @import_handler = DoubleDoc::ImportHandler.new(*roots)
    end
  end
end
