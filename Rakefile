require "bundler/gem_tasks"

$LOAD_PATH.unshift 'lib'

require 'double_doc/task'

namespace :doc do
  desc "Clean generated documentation"
  task :clean do
    require 'fileutils'
    FileUtils.rm('readme.md')
  end

  desc "Generate documentation"
  DoubleDoc::Task.new(:generate, :sources => 'doc/readme.md', :destination => '.')
end


task :default => ['doc:clean', 'doc:generate']
