require 'rake'
require 'pathname'
require 'tmpdir'
require 'double_doc/import_handler'
require 'double_doc/html_generator'

module DoubleDoc

  ## ### Rake Task
  ## It is very easy to set up a rake task for generating your documentation. All you have to do is
  ## tell DoubleDoc what the input files are, and where you want the output to go. In the example,
  ## `double_doc` is picked to avoid conflicts with the `doc` rake task in rails.
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:double_doc,
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
  ## If you just want to use double_doc to generate your README.md for github, you should write your documentation in doc/README.md and put this in your Rakefile:
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:double_doc, :sources => 'doc/README.md', :md_destination => '.')
  ## ```
  ##
  ## Then all you have to do is to run `rake double_doc`, and you will have a `readme.md` in the root of your project.
  ##
  ## If you have a gh-pages branch set up in your repository, you can event run `rake doc:publish` to generate html documentation and push it to your github pages.
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def initialize(task_name, options)
      md_srcs  = [options[:sources]].flatten
      md_dst   = Pathname.new(options[:md_destination])
      html_dst = Pathname.new(options[:html_destination]) if options[:html_destination]

      destinations = [md_dst, html_dst].compact
      destinations.each do |dst|
        directory(dst.to_s)
      end

      desc "Generate markdown #{html_dst ? 'and HTML ' : ''}DoubleDoc documentation"
      generated_task = task(task_name => destinations) do |t, args|
        roots = Array(options[:root])
        roots << Rake.original_dir if roots.empty?
        roots << options.fetch(:import, {})

        import_handler = DoubleDoc::ImportHandler.new(*roots)

        sources = md_srcs.map do |source|
          if source =~ /\*/
            import_handler.load_paths.map do |path|
              Dir.glob(File.join(path, source))
            end
          else
            import_handler.find_file(source).path
          end
        end.flatten.uniq

        generated_md_files = []

        sources.each do |src|
          dst = md_dst + File.basename(src)
          puts "#{src} -> #{dst}"

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

        if html_dst || args[:html_destination]
          html_generator = DoubleDoc::HtmlGenerator.new(generated_md_files, options.merge(args))
          html_generator.generate
        end

      end

      has_github_pages = !`git branch | grep 'gh-pages'`.empty? rescue false

      if has_github_pages
        namespace(task_name) do
          desc "Publish DoubleDoc documentation to Github Pages"
          task :publish do
            git_clean = `git status -s`.empty? rescue false
            raise "Your local git repository needs to be clean for this task to run" unless git_clean

            git_branch = `git branch | grep "*"`.match(/\* (.*)/)[1] rescue 'master'

            Dir.mktmpdir do |dir|
              generated_task.execute(:html_destination => dir)
              html_files = Dir.glob(Pathname.new(dir) + '*.html')

              `git add .`
              `git commit -n -m 'Updated documentation'`
              `git checkout gh-pages`
              `git pull origin gh-pages`
              `cp #{dir}/* .`
              if html_files.size == 1
                `cp #{html_files[0]} index.html`
              else
                warn("You should probably generate an index.html")
              end
              `git add .`
              `git commit -n -m 'Updated Github Pages'`
              `git push origin gh-pages`
              `git checkout #{git_branch}`
            end
          end
        end
      end
    end

  end
end
