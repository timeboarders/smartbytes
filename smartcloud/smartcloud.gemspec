# frozen_string_literal: true

version = File.read(File.expand_path("../SMARTBYTES_VERSION", __dir__)).strip

Gem::Specification.new do |s|
	s.platform    	= Gem::Platform::RUBY
	s.name        	= "smartcloud"
	s.version     	= version
	s.summary     	= "Run smartapps out of the box."
	s.description 	= "SmartCloud is a framework to run smartapps out of the box encouraging natural simplicity by favoring convention over configuration."

	s.required_ruby_version     = ">= 2.5.0"

	s.license     	= "GPL-3.0-or-later"

	s.author     	= "Timeboard"
	s.email       	= "hello@timeboard.me"
	s.homepage    	= "https://github.com/timeboarders/smartbytes"

	s.executables 	= %w(smartcloud)

	s.files        	= Dir["CHANGELOG.rdoc", "MIT-LICENSE", "README.rdoc", "bin/**/*", "bin/**/.keep", "lib/**/*", "lib/**/.keep"]

	s.extra_rdoc_files = %w(README.rdoc)
	s.rdoc_options.concat ["--main",  "README.rdoc"]

	s.metadata		= {
		"bug_tracker_uri"   => "https://github.com/timeboarders/smartbytes/issues",
	    "changelog_uri"     => "https://github.com/timeboarders/smartbytes/blob/v#{version}/smartcloud/CHANGELOG.rdoc",
	    # "documentation_uri" => "https://www.timeboard.me/smartbytes/api/v#{version}/",
	    # "mailing_list_uri"  => "https://www.timeboard.me/smartbytes/discuss",
	    "source_code_uri"   => "https://github.com/timeboarders/smartbytes/tree/v#{version}/smartcloud"
	}

	s.add_dependency "net-ssh", "~> 5.2"
	s.add_dependency "bcrypt", "~> 3.1", ">= 3.1.13"
	s.add_dependency "activesupport", "~> 6.0"
end
