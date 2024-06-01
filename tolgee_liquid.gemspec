
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tolgee_liquid/version"

Gem::Specification.new do |spec|
  spec.name          = "tolgee_liquid"
  spec.version       = TolgeeLiquid::VERSION
  spec.authors       = ["Allen He"]
  spec.email         = ["pooopooo543@gmail.com"]

  spec.summary       = %q{Tolgee Integration for Liquid}
  spec.description   = %q{A gem that integrate Tolgee Platform to Shopify Liquid template engine.}
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'message_format', '~> 0.0.8'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.23"
end
