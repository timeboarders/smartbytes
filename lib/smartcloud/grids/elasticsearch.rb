# The main Smartcloud Grids Elasticsearch driver
module Smartcloud
	module Grids
		class Elasticsearch < Smartcloud::Base
			def initialize
			end

			def install
				self.uninstall

				print "-----> Creating settings for elasticsearch ... "

				vm_max_map_count_filepath = "~/.smartcloud/grids/grid-elasticsearch/vm_max_map_count"
				ssh = Smartcloud::SSH.new
				ssh.run "sudo sysctl -b vm.max_map_count > #{vm_max_map_count_filepath}"
				ssh.run "sudo sysctl -w vm.max_map_count=262144"

				puts "done"
			end

			def uninstall
				print "-----> Removing settings for elasticsearch ... "

				vm_max_map_count_filepath = "~/.smartcloud/grids/grid-elasticsearch/vm_max_map_count"
				ssh = Smartcloud::SSH.new
				ssh.run "test -f #{vm_max_map_count_filepath} && sudo sysctl -w vm.max_map_count=$(cat #{vm_max_map_count_filepath})"
				ssh.run "test -f #{vm_max_map_count_filepath} && rm #{vm_max_map_count_filepath}"

				puts "done"
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if Smartcloud::Docker.running?
					# Creating networks
					unless system("docker network inspect elasticsearch-network", [:out, :err] => File::NULL)
						print "-----> Creating network elasticsearch-network ... "
						if system("docker network create elasticsearch-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container elasticsearch ... "
					if system("docker create \
						--name='elasticsearch' \
						--env discovery.type=single-node \
						--env cluster.name=elasticsearch-cluster \
						--env 'ES_JAVA_OPTS=-Xms512m -Xmx512m -Des.enforce.bootstrap.checks=true' \
						--env bootstrap.memory_lock=true \
						--ulimit memlock=-1:-1 \
						--user `id -u`:`id -g` \
						#{"--publish='#{Smartcloud.credentials.elasticsearch[:port]}:#{Smartcloud.credentials.elasticsearch[:port]}'" if exposed == '--exposed'} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-elasticsearch/data:/usr/share/elasticsearch/data' \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-elasticsearch/logs:/usr/share/elasticsearch/logs' \
						--restart='always' \
						--network='elasticsearch-network' \
						elasticsearch:7.4.1", out: File::NULL)

						puts "done"
						print "-----> Starting container elasticsearch ... "
						if system("docker start elasticsearch", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container elasticsearch ... "
					if system("docker stop 'elasticsearch'", out: File::NULL)
						puts "done"
						print "-----> Removing container elasticsearch ... "
						if system("docker rm 'elasticsearch'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network elasticsearch-network ... "
					if system("docker network rm elasticsearch-network", out: File::NULL)
						puts "done"
					end
				end
			end			
		end
	end
end