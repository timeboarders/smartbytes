Gem::Specification.new do |s|
	s.name        	= 'smartcloud'
	s.version     	= '0.1.0.alpha'
	s.date        	= '2019-05-16'
	s.summary     	= "Full-stack web server framework."
	s.description 	= "Smartcloud is a full-stack web server framework optimized for programmer happiness and peaceful administration. It encourages natural simplicity by favoring convention over configuration."

	s.authors     	= ["Timeboard"]
	s.email       	= 'hello@timeboard.me'
	s.homepage    	= 'https://github.com/timeboardme/smartcloud'

	s.license     	= 'MIT'

	s.required_ruby_version     = ">= 2.5.0"
	s.required_rubygems_version = ">= 1.8.11"

	s.files        	= Dir["{lib}/**/*.rb", "{lib}/**/*.yml", "{lib}/**/*.conf", "{lib}/**/*.tmpl", "{lib}/**/*.keep", "bin/*", "test/**/*", "MIT-LICENSE", "*.md"]

	s.metadata		= {
		"source_code_uri" => "https://github.com/timeboardme/smartcloud"
	}

	s.executables 	<< 'smartcloud'
end