require 'pathname'
require 'double_doc/import_handler'

module DoubleDoc

  ## You can easly use DoubleDoc from Rake, and soon I'll tell you how...
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def initialize(task_name, options)
      @dst     = Pathname.new(options[:destination])
      @sources = FileList[*options[:sources]]
      import_handler = DoubleDoc::ImportHandler.new(options[:root] || Rake.original_dir)

      directory(@dst.to_s)
      task(task_name => @dst.to_s)

      @sources.each do |src|
        dst = @dst + File.basename(src)

        file(dst => (double_doc_source_files + [@dst.to_s, src])) do |f|
          verbose { puts "#{src} -> #{dst}" }
          File.open(dst, 'w') do |out|
            out.write(import_handler.resolve_imports(File.new(src)))
          end

          CLEAN.include(dst.to_s) if defined?(CLEAN)
        end

        task(task_name => dst)
      end
    end

    def double_doc_source_files
      libdir = File.expand_path('../..', __FILE__)
      FileList["#{libdir}/double_doc.rb", "#{libdir}/double_doc/**"]
    end
  end
end
