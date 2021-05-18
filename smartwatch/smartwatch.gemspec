# frozen_string_literal: true

require_relative 'lib/smart_watch/version'

Gem::Specification.new do |s|
	s.platform    	= Gem::Platform::RUBY
	s.name        	= "smartwatch"
	s.version     	= SmartWatch.version
	s.summary     	= "Full-stack deployment framework for Rails."
	s.description 	= "SmartWatch is a wrapper API for stock market investments."

	s.required_ruby_version     = Gem::Requirement.new(">= #{SmartWatch.ruby_version}")
	s.required_rubygems_version = ">= 1.8.11"

	s.license     	= "GPL-3.0-or-later"

	s.author      	= "Gaurav Goel"
	s.email       	= "gaurav@timeboard.me"
	s.homepage    	= "https://github.com/timeboardcode/smartwatch"

	s.files        	= Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "README.rdoc", "bin/**/*", "bin/**/.keep", "lib/**/*", "lib/**/.keep"]
  s.require_path  = "lib"

  s.bindir        = "exe"
	s.executables 	= ["smartwatch"]

	s.extra_rdoc_files = %w(README.rdoc)
	s.rdoc_options.concat ["--main",  "README.rdoc"]

	s.metadata		= {
    "homepage_uri"      => s.homepage,
    "bug_tracker_uri"   => "https://github.com/timeboardcode/smartwatch/issues",
    "changelog_uri"     => "https://github.com/timeboardcode/smartwatch/releases/tag/v#{SmartWatch.version}",
    # "documentation_uri" => "https://www.timeboard.me/about/software/smartwatch/api/v#{SmartWatch.version}/",
    # "mailing_list_uri"  => "https://www.timeboard.me/about/software/smartwatch/discuss",
    "source_code_uri"   => "https://github.com/timeboardcode/smartwatch/tree/v#{SmartWatch.version}"
	}

	s.add_dependency "net-ssh", "~> 5.2"
	s.add_dependency "bcrypt", "~> 3.1", ">= 3.1.13"
	s.add_dependency "activesupport", "~> 6.0"
  s.add_dependency "thor", '~> 1.0', '>= 1.0.1'
	s.add_dependency "bundler", '>= 2.1.4', "< 3.0.0"
	s.add_dependency "faraday", '~> 1.4', '>= 1.4.1'
end
