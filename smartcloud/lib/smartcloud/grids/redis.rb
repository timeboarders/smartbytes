# The main Smartcloud Grids Redis driver
module Smartcloud
	module Grids
		class Redis < Smartcloud::Base
			def initialize
			end

			def self.up
				if Smartcloud::Docker.running?
					# Creating networks
					unless system("docker network inspect redis-network", [:out, :err] => File::NULL)
						print "-----> Creating network redis-network ... "
						if system("docker network create redis-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container redis ... "
					if system("docker create \
						--name='redis' \
						--user `id -u`:`id -g` \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-redis/data:/data' \
						--restart='always' \
						--network='redis-network' \
						redis:6.0-rc3-alpine3.11 redis-server --appendonly yes", out: File::NULL)

						puts "done"
						print "-----> Starting container redis ... "
						if system("docker start redis", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container redis ... "
					if system("docker stop 'redis'", out: File::NULL)
						puts "done"
						print "-----> Removing container redis ... "
						if system("docker rm 'redis'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network redis-network ... "
					if system("docker network rm redis-network", out: File::NULL)
						puts "done"
					end
				end
			end
		end
	end
end