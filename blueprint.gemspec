# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blueprint/version'

Gem::Specification.new do |spec|
  spec.name          = 'blueprint'
  spec.version       = Blueprint::VERSION
  spec.authors       = [
    'Ewout Kleinsmann',
    'Roland Boon'
  ]
  spec.email         = 'info@10kb.nl'
  spec.homepage      = 'http://10kb.nl/'

  spec.summary       = 'Define attributes within models for automatic migration generators, schema composition and more'
  spec.description   = <<-DESC
    Blueprint allows you to define attributes within your models. This definition allows for
    automatic migration generation. You can also use blueprint for inheritance and composition
    of your model's attributes.
  DESC
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = Dir['test/**/*']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib vendor test)

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
end
