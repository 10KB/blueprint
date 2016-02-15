# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blueprint/version'

Gem::Specification.new do |spec|
  spec.name          = "blueprint"
  spec.version       = Blueprint::VERSION
  spec.authors       = ["Ewout Kleinsmann", "Roland Boon"]
  spec.email         = ["info@10kb.nl"]

  spec.summary       = %q{TODO: Write a short summary, because Rubygems requires one.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.test_files    = Dir["test/**/*"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "vendor"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_dependency             "parslet",       "~> 1.7"

  spec.add_development_dependency "bundler",       "~> 1.9"
  spec.add_development_dependency "rake",          "~> 10.0"
  spec.add_development_dependency "activesupport", "~> 4.2"
  spec.add_development_dependency "activerecord",  "~> 4.2"
  spec.add_development_dependency "pry"
end
