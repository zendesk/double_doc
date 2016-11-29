require 'rake'
require 'pathname'
require 'tmpdir'
require 'double_doc/client'

module DoubleDoc

  ## ### Rake Task
  ## Generate documentation by telling DoubleDoc what the input files are, and where the output should go.
  ## In the example, `double_doc` is picked to avoid conflicts with the `doc` rake task in rails.
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(
  ##   :double_doc,
  ##   sources:          'doc/source/*.md',
  ##   md_destination:   'doc/generated',
  ##   html_destination: 'site'
  ## )
  ## ```
  ##
  ## The available options are:
  ##
  ## | name                 | Description
  ## | -------------------- | -----------
  ## | __sources__          | __Required__. Documentation source directory (string or array of strings).
  ## | __md_destination__   | __Required__. Directory where the generated markdown files should go.
  ## | __html_destination__ | Where a pretty HTML version of the documentation should go.
  ## | __html_template__    | Custom ERB template for HTML rendering, see default template for inspiration (templates/default.html.erb).
  ## | __html_renderer__    | Custom html rendered, defaults to `DoubleDoc::HtmlRenderer`.
  ## | __html_css__         | Custom CSS document path.
  ## | __title__            | Title for generated HTML, defaults to "Documentation".
  ## To generate a README.md for github, write documentation in doc/README.md and put this in the Rakefile:
  ##
  ## ```ruby
  ## require 'double_doc'
  ##
  ## DoubleDoc::Task.new(:double_doc, sources: 'doc/README.md', md_destination: '.')
  ## ```
  ##
  ## Then run `rake double_doc`, which will generate a `readme.md` in the root of the project.
  ##
  ## If a gh-pages branch exists, run `rake doc:publish` to generate html documentation and push it to your github pages.
  class Task
    include Rake::DSL if defined?(Rake::DSL)

    def initialize(task_name, options)
      md_dst   = Pathname.new(options[:md_destination])
      html_dst = Pathname.new(options[:html_destination]) if options[:html_destination]

      destinations = [md_dst, html_dst].compact
      destinations.each do |dst|
        directory(dst.to_s)
      end

      roots = Array(options[:root])
      roots << Rake.original_dir if roots.empty?

      desc "Generate markdown #{html_dst ? 'and HTML ' : ''}DoubleDoc documentation"
      generated_task = task(task_name => destinations) do |t, args|
        opts = args.to_h.merge(options.merge(:roots => roots))
        client = DoubleDoc::Client.new(options[:sources], opts)
        client.process
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

              # FIXME: fail when something fails and don't just continue
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
