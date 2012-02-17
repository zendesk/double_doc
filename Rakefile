require "bundler/gem_tasks"

$LOAD_PATH.unshift 'lib'

require 'double_doc/task'

desc "Generate documentation"
DoubleDoc::Task.new(:doc, :sources => 'doc/readme.md', :md_destination => '.', :html_destination => 'site')


task :default => [:doc]
