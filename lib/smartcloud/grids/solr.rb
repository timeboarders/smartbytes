# The main Smartcloud Grids Solr driver
module Smartcloud
	module Grids
		class Solr
			def initialize
			end

			def self.start
				puts "-----> Starting Solr Network"

				# Give the ownership of solr folder to 8983 for solr to use properly
				system("sudo chown -R 8983:8983 #{self.solr_datapath}")

				system("docker-compose -f #{self.docker_compose_filepath} up -d")
			end
	
			def self.stop
				puts "-----> Stopping Solr Network"
				system("docker-compose -f #{self.docker_compose_filepath} down")
			end

			def self.create_core(corename)
				system("sudo docker exec -it --user=solr solr solr create_core -c #{corename} -d sunspot")
			end

			def self.destroy_core(corename)
				system("sudo docker exec -it --user=solr solr solr delete -c ${corename}")
			end

			def self.docker_compose_filepath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-solr/docker-compose.yml')
			end

			def self.solr_datapath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-solr/solr')
			end
		end
	end
end