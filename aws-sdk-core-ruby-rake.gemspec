# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aws-sdk-core-ruby-rake'

Gem::Specification.new do |spec|
  spec.name          = "aws-sdk-core-ruby-rake"
  spec.version       = AwsSdkCoreRubyRake::VERSION
  spec.authors       = ["Michael Mell"]
  spec.email         = ["michael.mell@brightbytes.net"]
  spec.summary       = %q{Rake wrapper for aws-sdk-core-ruby (sdk v2).}
  spec.description   = %q{Rake wrapper for aws-sdk-core-ruby (sdk v2).}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_dependency "aws-sdk"
  spec.add_dependency "highline"
end
