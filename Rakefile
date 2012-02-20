$LOAD_PATH.unshift 'lib'
require "bundler/gem_tasks"
require 'double_doc/task'
require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs   << 'lib'
  test.libs   << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

DoubleDoc::Task.new(:doc,
  :title            => 'API Documentaion',
  :sources          => 'doc/README.md',
  :md_destination   => '.',
  :html_destination => 'site'
)

task :default => [:test]
