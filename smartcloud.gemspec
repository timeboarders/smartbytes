Gem::Specification.new do |s|
	s.name        	= 'smartcloud'
	s.version     	= '0.0.2'
	s.summary     	= "Full-stack deployment framework for Rails."
	s.description 	= "Smartcloud is a full-stack deployment framework for rails optimized for programmer happiness and peaceful administration. It encourages natural simplicity by favoring convention over configuration."

	s.authors     	= ["Timeboard"]
	s.email       	= 'hello@timeboard.me'
	s.homepage    	= 'https://github.com/timeboardme/smartcloud'

	s.license     	= 'MIT'

	s.required_ruby_version     = ">= 2.5.0"
	s.required_rubygems_version = ">= 1.8.11"

	s.files        	= Dir.glob("{bin,lib}/**/*") + Dir.glob("{bin,lib}/**/.keep") + %w(MIT-LICENSE README.md)

	s.metadata		= {
		"source_code_uri" => "https://github.com/timeboardme/smartcloud"
	}

	s.executables 	<< 'smartcloud'
end