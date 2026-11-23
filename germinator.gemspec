$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "germinator/version"


# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "germinator"
  s.version     = Germinator::VERSION
  s.authors     = ["Wowza Media Systems"]
  s.email       = ["platform+rubygems@wowza.com"]
  s.homepage    = "http://www.wowza.com"
  s.summary     = "Adds the ability to generate and execute sequential/incremental seed files."
  s.description = "Rails allows incremental database migrations, but only provides a single seed file (non-incremental) that causes problems when you try to run it during each application deploy. Germinate provides a process very similar to the Rails database migrations that allows you to ensure that a data seed only gets run once in each environment. It also provides a way to limit which Rails environments are allowed to run particular seeds, which helps protect data in sensitive environments (e.g. Production)."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "actionview", ">= 6.0.3.3", "< 9"
  s.add_development_dependency "rspec", "~> 3.13"
end
