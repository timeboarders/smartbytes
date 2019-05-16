# The main Smartcloud Grids Solr driver
module Smartcloud
	module Grids
		class Solr
			def initialize
			end

			def self.start
				# echo "-----> Setting up data folder used by solr"
				# # Give the ownership of solr folder to 8983 for solr to use properly
				# sudo chown -R 8983:8983 ./solr
				#
				# echo "-----> Starting Solr Network"
				# docker-compose up -d
			end
	
			def self.stop
				# echo "-----> Stopping Solr Network"
				# docker-compose down
			end

			def self.create_core
				# solr_corename=$1
				# sudo docker exec -it --user=solr solr solr create_core -c ${solr_corename} -d sunspot
			end

			def self.destroy_core
				# solr_corename=$1
				# sudo docker exec -it --user=solr solr solr delete -c ${solr_corename}
			end

			def self.docker_compose_filepath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-solr/docker-compose.yml')
			end
		end
	end
end