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

task :setup_bundle_fixtures do
  unless File.exist?(Bundler.root.join("test/fixtures/Gemfile.lock"))
    fail("Please run \"bundle install --gemfile=test/fixtures/Gemfile --local\" before running rake")
  end
end

task :test => [:setup_bundle_fixtures]
task :default => [:test]

desc 'test release and publish'
task :release_and_publish => [:test, :release, 'doc:publish']
