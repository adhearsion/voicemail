# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "voicemail/version"

Gem::Specification.new do |s|
  s.name        = "voicemail"
  s.version     = Voicemail::VERSION
  s.authors     = ["Luca Pradovera"]
  s.email       = ["lpradovera@mojolingo.com"]
  s.homepage    = "http://github.com/adhearsion/voicemail"
  s.summary     = %q{Voicemail for Adhearsion}
  s.description = %q{A simple, extensible voicemail implementation}

  s.rubyforge_project = "voicemail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, [">= 2.0.0"]
  s.add_runtime_dependency %q<adhearsion-asterisk>
  s.add_runtime_dependency %q<activesupport>, [">= 3.0.10"]

  s.add_development_dependency %q<bundler>
  s.add_development_dependency %q<rspec>, [">= 2.5.0"]
  s.add_development_dependency %q<yard>, ["~> 0.6.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
  s.add_development_dependency %q<flexmock>
 end
