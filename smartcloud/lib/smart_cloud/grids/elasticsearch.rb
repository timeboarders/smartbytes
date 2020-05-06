# The main Smartcloud Grids Elasticsearch driver
module Smartcloud
	module Grids
		class Elasticsearch < Smartcloud::Base
			def initialize
			end

			def install
				self.uninstall

				print "-----> Creating settings for elasticsearch ... "

				ssh = Smartcloud::SSH.new
				ssh.run "echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/60-smartcloud-elasticsearch.conf && sudo sysctl --system"

				puts "done"
			end

			def uninstall
				print "-----> Removing settings for elasticsearch ... "

				ssh = Smartcloud::SSH.new
				# NOTE: sysctl does not reset this setting until restart of system even after sudo sysctl --system is run.
				ssh.run "test -f /etc/sysctl.d/60-smartcloud-elasticsearch.conf && sudo rm /etc/sysctl.d/60-smartcloud-elasticsearch.conf && sudo sysctl --system"

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
						--ulimit nofile=65535:65535 \
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