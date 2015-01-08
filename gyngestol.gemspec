# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'gyngestol/version'

Gem::Specification.new do |s|
  s.name        = "gyngestol"
  s.version     = Gyngestol::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ragmaanir"]
  s.email       = ["ragmaanir@gmail.com"]
  s.homepage    = "http://github.com/ragmaanir/gyngestol"
  s.summary     = "A rack-based ruby framework for defining APIs"
  s.description = "A rack-based ruby framework for defining APIs. Actions are regular methods annotated with a DSL. A rake task is included to generate documentation for the API."

  s.required_rubygems_version = "~> 2.2"
  s.required_ruby_version     = "~> 2.1"
  s.rubyforge_project         = "gyngestol"

  s.add_runtime_dependency 'rack', '~> 1.6'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
  s.add_runtime_dependency 'virtus', '~> 1.0'
  s.add_runtime_dependency 'ice_nine', '~> 0.11'

  s.add_development_dependency "rspec", '~> 3.0'
  s.add_development_dependency 'rack-test', '~> 0.6'
  s.add_development_dependency 'wrong', '~> 0.7'
  s.add_development_dependency 'rerun', '~> 0.10'

  s.add_development_dependency 'pry', '~> 0.9'
  s.add_development_dependency 'binding_of_caller', '~> 0.7'

  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.test_files   = Dir.glob("spec/**/*_spec.rb")
  s.require_path = 'lib'
end
