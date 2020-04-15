# frozen_string_literal: true

version = File.read(File.expand_path("SMARTBYTES_VERSION", __dir__)).strip

Gem::Specification.new do |s|
	s.name        	= 'smartmachine'
	s.version     	= version
	s.summary     	= "SmartMachine"
	s.description 	= "A safe place for SmartMachine."
	s.authors     	= ["Timeboard"]
	s.email       	= 'hello@timeboard.me'
	s.homepage    	= 'https://rubygems.org/gems/smartmachine'
	s.license     	= 'MIT'

	s.files	= ["MIT-LICENSE", "README.md"]
end
