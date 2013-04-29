# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hashup/version'

Gem::Specification.new do |spec|
  spec.name          = "hashup"
  spec.version       = Hashup::VERSION
  spec.authors       = ["krazy"]
  spec.email         = ["lixiangstar@gmail.com"]
  spec.description   = %q{yet another static sites generator}
  spec.summary       = %q{a generator}
  spec.homepage      = "http://github.io/krazylee"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = 'hashup'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "thor"
  spec.add_development_dependency "markascend"
  spec.add_development_dependency "pygments"
end
