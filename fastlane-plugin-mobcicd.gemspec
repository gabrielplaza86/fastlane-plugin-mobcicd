lib = File.expand_path("code/lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/mobcicd/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-mobcicd'
  spec.version       = Fastlane::Mobcicd::VERSION
  spec.author        = 'Gabriel Plaza'

  spec.summary       = 'Fastlane plugin to better manage CI module updates'
  #spec.homepage      = "https://github.com/gabrielplaza86/fastlane-plugin-mobcicd"
  spec.license       = "MIT"

  spec.files         = Dir["code/lib/**/*"] + %w(README.md LICENSE)
  spec.require_paths = ['code/lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  #spec.add_dependency 'your-dependency', '~> 1.0.0'
end
