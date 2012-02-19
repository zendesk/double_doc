require 'guard'
require 'guard/guard'
require 'rake'

module Guard
  class DoubleDoc < Guard
    include ::Rake::DSL

    def start
      load 'Rakefile'
      true
    end

    def reload
      stop
      start
    end

    def run_all
      run_rake_task
    end

    def run_on_change(paths)
      run_rake_task
    end

    def run_rake_task
      UI.info "generating double docs"
      ::Rake::Task.tasks.each { |t| t.reenable }
      ::Rake::Task[@options[:rake_task]].invoke
    end
  end
end
