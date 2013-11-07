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

  s.files         = Dir.glob("{lib,templates}/**/*") + ["readme.md"]
  s.test_files    = Dir.glob("test/**/*")
  s.require_paths = ["lib"]

  s.add_development_dependency "guard", "~> 1.6"
  s.add_development_dependency "minitest"

  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "erubis"
  s.add_runtime_dependency "redcarpet", "~> 2.1"
  s.add_runtime_dependency "pygments.rb", "~> 0.2"
end
