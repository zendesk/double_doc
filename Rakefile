require "bundler/setup"
require "bundler/gem_tasks"
require "double_doc/task"
require "rake/testtask"
require "bump/tasks"

Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.warning = false # TODO: turn on and fix
end

DoubleDoc::Task.new(
  :doc,
  :title            => 'API Documentation',
  :sources          => 'doc/readme.md',
  :md_destination   => '.',
  :html_destination => 'site'
)

task default: [:test]
