# The main Smartcloud Grids Solr driver
module Smartcloud
	module Grids
		class Solr < Smartcloud::Base
			def initialize
			end

			def self.up(exposed)
				if Smartcloud::Docker.running?
					# Creating networks
					unless system("docker network inspect solr-network", [:out, :err] => File::NULL)
						print "-----> Creating network solr-network ... "
						if system("docker network create solr-network", out: File::NULL)
							puts "done"
						end
					end

					print "-----> Settings permissions solr ... "
					if system("sudo chown -R 8983:8983 #{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-solr/data", out: File::NULL)
						puts "done"
					end

					# Creating & Starting containers
					print "-----> Creating container solr ... "
					if system("docker create \
						--name='solr' \
						#{"--publish='8983:8983'" if exposed == '--exposed'} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-solr/data:/opt/solr/server/solr' \
						--restart='always' \
						--network='solr-network' \
						solr:7.5.0", out: File::NULL)

						puts "done"
						print "-----> Starting container solr ... "
						if system("docker start solr", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container solr ... "
					if system("docker stop 'solr'", out: File::NULL)
						puts "done"
						print "-----> Removing container solr ... "
						if system("docker rm 'solr'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network solr-network ... "
					if system("docker network rm solr-network", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.create_core(corename)
				if Smartcloud::Docker.running?
					puts "-----> Creating core #{corename} ... "
					if system("docker exec -it --user=solr solr solr create_core -c #{corename}")
						system("docker exec -it --user=solr solr solr config -c #{corename} -p 8983 -action set-user-property -property update.autoCreateFields -value false")
						puts "done"

						print "-----> Copying core files ... "
						system("sudo cp -r #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-solr/sunspot/conf/* #{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-solr/data/#{corename}/conf/")
						if system("sudo chown -R 8983:8983 #{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-solr/data/#{corename}/conf", out: File::NULL)
							puts "done"
						end
					else
						puts "error"
					end
				end
			end

			def self.destroy_core(corename)
				if Smartcloud::Docker.running?
					puts "-----> Removing core #{corename} ... "
					if system("docker exec -it --user=solr solr solr delete -c #{corename}")
						puts "done"
					else
						puts "error"
					end
				end
			end
		end
	end
end