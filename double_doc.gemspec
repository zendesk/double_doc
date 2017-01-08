require "./lib/double_doc/version"

Gem::Specification.new do |s|
  s.name        = "double_doc"
  s.version     = DoubleDoc::VERSION
  s.authors     = ["Mick Staugaard"]
  s.email       = ["mick@staugaard.com"]
  s.homepage    = "https://github.com/zendesk/double_doc"
  s.summary     = "Documentation right where you want it"
  s.description = "Write documentation with your code, to keep them in sync, ideal for public API docs."

  s.files       = Dir.glob("{lib,templates}/**/*") + ["readme.md"]

  s.add_development_dependency "guard", "~> 1.6"
  s.add_development_dependency "maxitest"
  s.add_development_dependency "mime-types"
  s.add_development_dependency "bump"

  s.add_runtime_dependency "rake"
  s.add_runtime_dependency "erubis"
  s.add_runtime_dependency "redcarpet", "< 4"
  s.add_runtime_dependency "pygments.rb", "~> 1.1.1"
end
