# frozen_string_literal: true

require_relative "lib/smart_kit/version"

Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name          = "smartkit"
  spec.version       = SmartKit::VERSION
  spec.authors       = ["Timeboard"]
  spec.email         = ["support@timeboard.me"]

  spec.summary       = "SmartKit Summary."
  spec.description   = "SmartKit Description."
  spec.homepage      = "https://github.com/timeboardcode/smartbytes/tree/v#{SmartKit::VERSION}/smartkit"
  spec.license       = "GPL-3.0-or-later"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata = {
    "homepage_uri"      => spec.homepage,
    "bug_tracker_uri"   => "https://github.com/timeboardcode/smartbytes/issues",
    "changelog_uri"     => "https://github.com/timeboardcode/smartbytes/releases/tag/v#{SmartKit::VERSION}",
    "source_code_uri"   => "https://github.com/timeboardcode/smartbytes/tree/v#{SmartKit::VERSION}/smartkit"
    # "documentation_uri" => "https://www.timeboard.me/about/free-software/smartbytes/api/v#{version}/",
    # "mailing_list_uri"  => "https://www.timeboard.me/about/free-software/smartbytes/smartos/discuss",
  }

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["CODE_OF_CONDUCT.md", "LICENSE.txt", "README.md", "bin/**/*", "bin/**/.keep", "lib/**/*", "lib/**/.keep"]

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
