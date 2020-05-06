# The main SmartCloud Grids Mysql driver
module SmartCloud
	module Grids
		class Mysql < SmartCloud::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartCloud::Docker.running?
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
						--env MYSQL_ROOT_PASSWORD=#{SmartCloud.credentials.mysql[:root_password]} \
						--env MYSQL_USER=#{SmartCloud.credentials.mysql[:username]} \
						--env MYSQL_PASSWORD=#{SmartCloud.credentials.mysql[:password]} \
						--env MYSQL_DATABASE=#{SmartCloud.credentials.mysql[:database_name]} \
						--user `id -u`:`id -g` \
						#{"--publish='#{SmartCloud.credentials.mysql[:port]}:#{SmartCloud.credentials.mysql[:port]}'" if exposed == '--exposed'} \
						--volume='#{SmartCloud.config.user_home_path}/.smartcloud/grids/mysql/data:/var/lib/mysql' \
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
				if SmartCloud::Docker.running?
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