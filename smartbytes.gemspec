# frozen_string_literal: true

version = File.read(File.expand_path("SMARTBYTES_VERSION", __dir__)).strip

Gem::Specification.new do |s|
	s.name        	= 'smartbytes'
	s.version     	= version
	s.summary     	= "Smartbytes"
	s.description 	= "A safe place for smartbytes."
	s.authors     	= ["Timeboard"]
	s.email       	= 'hello@timeboard.me'
	s.homepage    	= 'https://rubygems.org/gems/smartbytes'
	s.license     	= 'MIT'

	s.files	= ["MIT-LICENSE", "README.md"]
end
