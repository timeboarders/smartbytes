# frozen_string_literal: true

version = File.read(File.expand_path("./SMARTBYTES_VERSION", __dir__)).strip

Gem::Specification.new do |s|
	s.platform    	= Gem::Platform::RUBY
	s.name        	= "smartbytes"
	s.version     	= version
	s.summary     	= "Smartbytes"
	s.description 	= "A safe place for smartbytes."

	s.required_ruby_version     = ">= 2.5.0"
	s.required_rubygems_version = ">= 1.8.11"

	s.license     	= "GPL-3.0-or-later"

	s.author     	= "Timeboard"
	s.email       	= "hello@timeboard.me"
	s.homepage    	= "https://github.com/timeboarders/smartbytes"

	s.files        	= ["README.rdoc"]

	s.metadata		= {
		"bug_tracker_uri"   => "https://github.com/timeboarders/smartbytes/issues",
	    "changelog_uri"     => "https://github.com/timeboarders/smartbytes/releases/tag/v#{version}",
	    # "documentation_uri" => "https://www.timeboard.me/smartbytes/api/v#{version}",
	    # "mailing_list_uri"  => "https://www.timeboard.me/smartbytes/discuss",
	    "source_code_uri"   => "https://github.com/timeboarders/smartbytes/tree/v#{version}"
	}

	s.add_dependency "smartcloud", version
	s.add_dependency "smartmachine", version
end
