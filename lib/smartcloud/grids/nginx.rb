# The main Smartcloud Grids Nginx driver
module Smartcloud
	module Grids
		class Nginx
			def initialize
			end
	
			def self.start
				puts "-----> Starting Nginx Network"
				system("docker-compose -f #{self.docker_compose_filepath} up -d") if self.docker_running? && self.has_docker_compose?
			end

			def self.stop
				puts "-----> Stopping Nginx Network"
				system("docker-compose -f #{self.docker_compose_filepath} down") if self.docker_running? && self.has_docker_compose?
			end
	
			def self.docker_compose_filepath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-nginx/docker-compose.yml')
			end

			def self.docker_running?
				if system("docker info", err: File::NULL)
					true
				else
					puts "Error: Docker daemon is not running. Have you installed docker? Please ensure docker daemon is running and try again."
					false
				end
			end

			def self.has_docker_compose?
				if system("which docker-compose", err: File::NULL)
					true
				else
					puts "Error: docker-compose is not installed. Please ensure docker-compose is running and try again."
					false
				end
			end
		end
	end
end
