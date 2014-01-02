# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "voicemail/version"

Gem::Specification.new do |s|
  s.name        = "voicemail"
  s.version     = Voicemail::VERSION
  s.authors     = ["Luca Pradovera", "Justin Aiken"]
  s.email       = ["lpradovera@mojolingo.com", "jaiken@mojolingo.com"]
  s.license     = 'MIT'
  s.homepage    = "http://github.com/adhearsion/voicemail"
  s.summary     = %q{Voicemail for Adhearsion}
  s.description = %q{A simple, extensible voicemail implementation}

  s.rubyforge_project = "voicemail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency %q<adhearsion>, ["~> 2.4"]

  s.add_development_dependency %q<bundler>
  s.add_development_dependency %q<rspec>, ["~> 2.14.0"]
  s.add_development_dependency %q<yard>, ["~> 0.6.0"]
  s.add_development_dependency %q<rake>, [">= 0"]
  s.add_development_dependency %q<guard-rspec>
  s.add_development_dependency %q<flexmock>
  s.add_development_dependency %q<ahnsay>
 end
