$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sibu/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sibu"
  s.version     = Sibu::VERSION
  s.authors     = ["Jean-Baptiste Vilain"]
  s.email       = ["jbvilain@gmail.com"]
  s.homepage    = "http://hotentic.com"
  s.summary     = "Sibu - A Site Builder for Ruby on Rails"
  s.description = "Sibu is an engine for Ruby on Rails that enables creation of static websites in a simple & wysiwyg way."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0"
  s.add_dependency "pg", "~> 1.0"
  s.add_dependency "shrine", "~> 2.8"
  s.add_dependency "image_processing", "~> 0.4"
  s.add_dependency "mini_magick", "~> 4.3"
  s.add_dependency "sass-rails", "~> 5.0"
end
