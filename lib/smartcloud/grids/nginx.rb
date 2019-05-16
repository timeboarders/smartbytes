# The main Smartcloud Grids Nginx driver
module Smartcloud
	module Grids
		class Nginx
			def initialize
			end
	
			def self.start
				puts "-----> Starting Nginx Network"
				system("docker-compose -f #{self.docker_compose_filepath} up -d")
			end

			def self.stop
				puts "-----> Stopping Nginx Network"
				system("docker-compose -f #{self.docker_compose_filepath} down")
			end
	
			def self.docker_compose_filepath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-nginx/docker-compose.yml')
			end
		end
	end
end
