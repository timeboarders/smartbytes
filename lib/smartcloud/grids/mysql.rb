# The main Smartcloud Grids Mysql driver
module Smartcloud
	module Grids
		class Mysql < Smartcloud::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if Smartcloud::Docker.running?
					# Creating networks
					unless system("docker network inspect mysql-network", [:out, :err] => File::NULL)
						print "-----> Creating network mysql-network ... "
						if system("docker network create mysql-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container mysql ... "
					if system("docker create \
						--name='mysql' \
						--env MYSQL_RANDOM_ROOT_PASSWORD=yes \
						--user `id -u`:`id -g` \
						#{"--publish='3306:3306'" if exposed == '--exposed'} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-mysql/data:/var/lib/mysql' \
						--restart='always' \
						--network='mysql-network' \
						mysql:8.0.18", out: File::NULL)

						puts "done"
						print "-----> Starting container mysql ... "
						if system("docker start mysql", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container mysql ... "
					if system("docker stop 'mysql'", out: File::NULL)
						puts "done"
						print "-----> Removing container mysql ... "
						if system("docker rm 'mysql'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network mysql-network ... "
					if system("docker network rm mysql-network", out: File::NULL)
						puts "done"
					end
				end
			end			
		end
	end
end