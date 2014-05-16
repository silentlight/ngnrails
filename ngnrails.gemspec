$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ngnrails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ngnrails"
  s.version     = Ngnrails::VERSION
  s.authors     = ["Bartosz Hejman"]
  s.email       = ["bartoszhejman@gmail.com"]
  s.homepage    = "http://www.synergeelabs.com/ngnrails"
  s.summary     = "Rails + AngularJS"
  s.description = "Generators to make integration between AngularJS and Rails easier"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.1"

  s.add_development_dependency "sqlite3"
end
