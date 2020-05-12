# The main SmartMachine Grids Elasticsearch driver
module SmartMachine
	class Grids
		class Elasticsearch < SmartMachine::Base
			def initialize
			end

			def install
				puts "-----> Installing Elasticsearch"

				print "-----> Creating settings for elasticsearch ... "
				ssh = SmartMachine::SSH.new
				ssh.run "echo 'vm.max_map_count=262144' | sudo tee /etc/sysctl.d/60-smartmachine-elasticsearch.conf && sudo sysctl --system"
				puts "done"

				puts "-----> Elasticsearch Installation Complete"
			end

			def uninstall
				puts "-----> Uninstalling Elasticsearch"

				print "-----> Removing settings for elasticsearch ... "
				ssh = SmartMachine::SSH.new
				# NOTE: sysctl does not reset this setting until restart of system even after sudo sysctl --system is run.
				ssh.run "test -f /etc/sysctl.d/60-smartmachine-elasticsearch.conf && sudo rm /etc/sysctl.d/60-smartmachine-elasticsearch.conf && sudo sysctl --system"
				puts "done"

				puts "-----> Elasticsearch Uninstallation Complete"
			end

			def update
				self.uninstall
				self.install
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartMachine::Docker.running?
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
						#{"--publish='#{SmartMachine.credentials.elasticsearch[:port]}:#{SmartMachine.credentials.elasticsearch[:port]}'" if exposed == '--exposed'} \
						--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/elasticsearch/data:/usr/share/elasticsearch/data' \
						--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/elasticsearch/logs:/usr/share/elasticsearch/logs' \
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
				if SmartMachine::Docker.running?
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