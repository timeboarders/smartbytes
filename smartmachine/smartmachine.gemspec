# frozen_string_literal: true

require_relative 'lib/smart_machine/version'

Gem::Specification.new do |s|
	s.platform    	= Gem::Platform::RUBY
	s.name        	= "smartmachine"
	s.version     	= SmartMachine.version
	s.summary     	= "Full-stack deployment framework for Rails."
	s.description 	= "SmartMachine is a full-stack deployment framework for rails optimized for admin programmer happiness and peaceful administration. It encourages natural simplicity by favoring convention over configuration."

	s.required_ruby_version     = Gem::Requirement.new(">= #{SmartMachine.ruby_version}")
	s.required_rubygems_version = ">= 1.8.11"

	s.license     	= "MIT"

	s.author      	= "Gaurav Goel"
	s.email       	= "gaurav@timeboard.me"
	s.homepage    	= "https://github.com/timeboardcode/smartmachine"

	s.files        	= Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "README.rdoc", "bin/**/*", "bin/**/.keep", "lib/**/*", "lib/**/.keep"]
  s.require_path  = "lib"

  s.bindir        = "exe"
	s.executables 	= ["smartmachine"]

	s.extra_rdoc_files = %w(README.rdoc)
	s.rdoc_options.concat ["--main",  "README.rdoc"]

	s.metadata		= {
    "homepage_uri"      => s.homepage,
    "bug_tracker_uri"   => "https://github.com/timeboardcode/smartmachine/issues",
    "changelog_uri"     => "https://github.com/timeboardcode/smartmachine/releases/tag/v#{SmartMachine.version}",
    # "documentation_uri" => "https://www.timeboard.me/about/software/smartmachine/api/v#{SmartMachine.version}/",
    # "mailing_list_uri"  => "https://www.timeboard.me/about/software/smartmachine/discuss",
    "source_code_uri"   => "https://github.com/timeboardcode/smartmachine/tree/v#{SmartMachine.version}"
	}

	s.add_dependency "net-ssh", "~> 5.2"
	s.add_dependency "bcrypt", "~> 3.1", ">= 3.1.13"
	s.add_dependency "activesupport", "~> 6.0"
  s.add_dependency "thor", '~> 1.0', '>= 1.0.1'
	s.add_dependency "bundler", '>= 2.1.4', "< 3.0.0"
end
