# coding: utf-8
$:.unshift './lib'
require 'ipatools'

Gem::Specification.new do |spec|
  spec.name          = "ipatools"
  spec.version       = Ipatools::VERSION
  spec.authors       = ["Dmitriy Kurkin"]
  spec.email         = ["kurd1983@mail.ru"]
  spec.summary       = "Set of ios tools for packing and signing ipa"
  spec.description   = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json", "~> 1.8"
  spec.add_dependency "faraday", "~> 0.8.9"
  spec.add_dependency "faraday_middleware", "~> 0.9"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
