# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "voicemail/version"

Gem::Specification.new do |s|
  s.name        = "voicemail"
  s.version     = Voicemail::VERSION
  s.authors     = ["Plugin Author"]
  s.email       = ["author@plugin.com"]
  s.homepage    = ""
  s.summary     = %q{Basic Voicemail}
  s.description = %q{A simple voicemail implementation}

  s.rubyforge_project = "voicemail"

  # Use the following if using Git
  # s.files         = `git ls-files`.split("\n")
  # s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = Dir.glob("{lib}/**/*") + %w( README.md Rakefile Gemfile)
  s.test_files    = Dir.glob("{spec}/**/*")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, [">= 2.0.0"]
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]

  s.add_development_dependency %q<bundler>
  s.add_development_dependency %q<rspec>, [">= 2.5.0"]
  s.add_development_dependency %q<ci_reporter>, [">= 1.6.3"]
  s.add_development_dependency %q<simplecov>, [">= 0"]
  s.add_development_dependency %q<simplecov-rcov>, [">= 0"]
  s.add_development_dependency %q<yard>, ["~> 0.6.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
  s.add_development_dependency %q<cucumber>
  s.add_development_dependency %q<aruba>
  s.add_development_dependency %q<flexmock>
 end
