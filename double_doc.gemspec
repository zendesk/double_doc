# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "double_doc/version"

Gem::Specification.new do |s|
  s.name        = "double_doc"
  s.version     = DoubleDoc::VERSION
  s.authors     = ["Mick Staugaard"]
  s.email       = ["mick@staugaard.com"]
  s.homepage    = "http://staugaard.github.com/double_doc"
  s.summary     = "Documentation right where you want it"
  s.description = "A simple framework for writing and generating beautiful documentation for your code"

  s.rubyforge_project = "double_doc"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rake"

  s.add_runtime_dependency "erubis"
  s.add_runtime_dependency "redcarpet"
  s.add_runtime_dependency "pygments.rb"
end
