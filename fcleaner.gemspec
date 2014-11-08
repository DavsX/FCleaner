# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fcleaner/version'

Gem::Specification.new do |spec|
  spec.name          = "FCleaner"
  spec.version       = FCleaner::VERSION
  spec.authors       = ["Davs"]
  spec.email         = ["kovdavid@gmail.com"]
  spec.summary       = %q{Cleanes one's Facebook Activity Log}
  spec.homepage      = "https://github.com/DavsX/FCleaner"
  spec.description   = %q{FCleaner allows cleaning the Activity Log on Facebook}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "mechanize"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
