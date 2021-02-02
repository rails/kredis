require_relative "lib/kredis/version"

Gem::Specification.new do |s|
  s.name     = "kredis"
  s.version  = Kredis::VERSION
  s.authors  = [ "Kasper Timm Hansen", "David Heinemeier Hansson" ]
  s.email    = "david@hey.com"
  s.summary  = "Higher-level data structures built on Redis."
  s.homepage = "https://github.com/rails/kredis"
  s.license  = "MIT"

  s.required_ruby_version = ">= 2.7.0"
  s.add_dependency "rails", ">= 6.0.0"
  s.add_dependency "redis", "~> 4.0"

  s.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
end
