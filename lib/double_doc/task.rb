require 'pathname'
require 'double_doc/import_handler'

module DoubleDoc

  ## You can easly use DoubleDoc from Rake, and soon I'll tell you how...
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def initialize(task_name, options)
      md_dst   = Pathname.new(options[:md_destination])
      html_dst = Pathname.new(options[:html_destination]) if options[:html_destination]
      sources  = FileList[*options[:sources]]
      import_handler = DoubleDoc::ImportHandler.new(options[:root] || Rake.original_dir)

      destinations = [md_dst, html_dst].compact
      destinations.each do |dst|
        directory(dst.to_s)
      end

      task(task_name => destinations) do

        sources.each do |src|
          dst = md_dst + File.basename(src)
          verbose { puts "#{src} -> #{dst}" }
          File.open(dst, 'w') do |out|
            out.write(import_handler.resolve_imports(File.new(src)))
          end
        end

      end
    end

  end
end
