# coding: utf-8
lib  = File.expand_path('../lib',  __FILE__)
$LOAD_PATH.unshift(lib)  unless $LOAD_PATH.include?(lib)

test = File.expand_path('../test', __FILE__)
$LOAD_PATH.unshift(test) unless $LOAD_PATH.include?(test)

require 'whiteprint/version'

Gem::Specification.new do |spec|
  spec.name          = 'whiteprint'
  spec.version       = Whiteprint::VERSION
  spec.authors       = [
    'Ewout Kleinsmann',
    'Roland Boon'
  ]
  spec.email         = 'info@10kb.nl'
  spec.homepage      = 'http://10kb.nl/'

  spec.summary       = 'Define attributes within models for automatic migration generators, schema composition and more'
  spec.description   = <<-DESC
    Whiteprint allows you to define attributes within your models. This definition allows for
    automatic migration generation. You can also use whiteprint for inheritance and composition
    of your model's attributes.
  DESC
  spec.license       = 'MIT'

  spec.files         = Dir['{lib,vendor}/**/*', 'LICENSE', 'Rakefile', 'README.md']
  spec.test_files    = Dir['test/**/*']
  spec.require_paths = %w(lib vendor)

  spec.add_runtime_dependency     'parslet',          '~> 1.7'
  spec.add_runtime_dependency     'terminal-table',   '~> 1.4'
  spec.add_runtime_dependency     'highline',         '~> 1.7'

  spec.add_development_dependency 'bundler',          '~> 1.9'
  spec.add_development_dependency 'rake',             '~> 10.0'
  spec.add_development_dependency 'activesupport',    '~> 4.2'
  spec.add_development_dependency 'activerecord',     '~> 4.2'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'flay'
  spec.add_development_dependency 'flog'
  spec.add_development_dependency 'brakeman'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
