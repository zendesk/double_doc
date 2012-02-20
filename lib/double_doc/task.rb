require 'rake'
require 'pathname'
require 'double_doc/import_handler'
require 'double_doc/html_generator'

module DoubleDoc

  ## ### Rake Task
  ## It is very easy to set up a rake task for generating your documentation. All you have to do is
  ## tell DoubleDoc what the input files are, and where you want the output to go.
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:doc,
  ##   :sources          => 'doc/source/*.md',
  ##   :md_destination   => 'doc/generated',
  ##   :html_destination => 'site'
  ## )
  ## ```
  ##
  ## The available options are:
  ##
  ## | name                 | Description
  ## | -------------------- | -----------
  ## | __sources__          | __Required__. This tells Double doc where to look for the source of the documentation. Can be either a string or an array of strings.
  ## | __md_destination__   | __Required__. This is the directory where you want the generated markdown files to go.
  ## | __html_destination__ | If you want a pretty HTML version of your documentation, all you have to do is to say where you want it.
  ## | __html_template__    | You can use your own custom ERB template for HTML rendering. Have a look in the one we ship with DoubleDoc for inspiration (templates/default.html.erb).
  ## | __html_renderer__    | If you want full control of the HTML rendering you can use your own implementation. Defaults to `DoubleDoc::HtmlRenderer`.
  ## | __html_css__         | You can use your own custom CSS document by specifying it's path here.
  ## | __title__            | The title you want in the generated HTML. Defaults to "Documentation".
  ##
  ## If you just want to use double doc to generate your readme.md for github, you should write your documentation in doc/readme.md and put his in your Rakefile:
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:doc, :sources => 'doc/readme.md', :md_destination => '.')
  ## ```
  ## Then all you have to do is to run `rake doc`, and you will have a `readme.md` in the root of your project.
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def initialize(task_name, options)
      md_dst   = Pathname.new(options[:md_destination])
      html_dst = Pathname.new(options[:html_destination]) if options[:html_destination]
      sources  = FileList[*options[:sources]]

      destinations = [md_dst, html_dst].compact
      destinations.each do |dst|
        directory(dst.to_s)
      end

      desc "Generate markdown #{html_dst ? 'and HTML ' : ''}DoubleDoc documentation from #{sources.join(', ')}"
      task(task_name => destinations) do
        import_handler = DoubleDoc::ImportHandler.new(options[:root] || Rake.original_dir)

        sources.each do |src|
          dst = md_dst + File.basename(src)
          puts "#{src} -> #{dst}"
          File.open(dst, 'w') do |out|
            out.write(import_handler.resolve_imports(File.new(src)))
          end
        end

        if html_dst
          html_generator = DoubleDoc::HtmlGenerator.new(FileList[(md_dst + '*.md').to_s].sort, options)
          html_generator.generate
        end

      end
    end

  end
end
