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
  ## If you just want to use double doc to generate your README.md for github, you should write your documentation in doc/README.md and put his in your Rakefile:
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:doc, :sources => 'doc/README.md', :md_destination => '.')
  ## ```
  ## Then all you have to do is to run `rake doc`, and you will have a `readme.md` in the root of your project.
  ##
  ## You can even run `rake doc:publish` to generate html documentation and push it to your Github Pages.
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
      generate_task = task(task_name => destinations) do |t, args|
        import_handler = DoubleDoc::ImportHandler.new(options[:root] || Rake.original_dir)

        sources.each do |src|
          dst = md_dst + File.basename(src)
          puts "#{src} -> #{dst}"
          File.open(dst, 'w') do |out|
            out.write(import_handler.resolve_imports(File.new(src)))
          end
        end

        if html_dst || args[:html_destination]
          html_generator = DoubleDoc::HtmlGenerator.new(FileList[(md_dst + '*.md').to_s].sort, options.merge(args))
          html_generator.generate
        end

      end

      namespace(task_name) do

        desc "Publish DoubleDoc documentation to Github Pages"
        task :publish do
          git_clean = `git status -s`.empty? rescue false
          raise "Your local git repository needs to be clean for this task to run" unless git_clean

          git_branch = `git branch | grep "*"`.match(/\* (.*)/)[1] rescue 'master'

          Dir.mktmpdir do |dir|
            generate_task.execute(:html_destination => dir)
            html_files = Dir.glob(Pathname.new(dir) + '*.html')

            `git add .`
            `git commit -m 'Updated documentation'`

            has_github_pages = !`git branch | grep 'gh-pages'`.empty? rescue false

            unless has_github_pages
              puts "Setting up gh-pages branch"

              `git symbolic-ref HEAD refs/heads/gh-pages`
              `rm .git/index`
              `git clean -fdx`
            else
              `git checkout gh-pages`
              `git pull origin gh-pages`
            end

            puts "Publishing your Github Pages"
            `cp #{dir}/* .`
            if html_files.size == 1
              `cp #{html_files[0]} index.html`
            else
              warn("You should probably generate an index.html")
            end

            `git add .`
            `git commit -m 'Updated Github Pages'`
            `git push origin gh-pages`
            `git co #{git_branch}`

            puts "Your Github Pages has been published. You will receive an email from Github when they are online."
          end
        end

      end
    end

  end
end
