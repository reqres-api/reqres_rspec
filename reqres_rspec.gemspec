# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reqres_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = 'reqres_rspec'
  spec.version       = ReqresRspec::VERSION
  spec.authors       = ['rilian']
  spec.email         = ['dmitriyis@gmail.com']
  spec.description   = %q{Generates API documentation in PDF, HTML, JSON, YAML format for integration tests written with RSpec}
  spec.summary       = %q{Generates API documentation in PDF, HTML, JSON, YAML format for integration tests written with RSpec}
  spec.homepage      = 'https://github.com/reqres-api/reqres_rspec'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'coderay'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
