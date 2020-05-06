# The main SmartMachine Grids Mysql driver
module SmartMachine
	module Grids
		class Mysql < SmartMachine::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartMachine::Docker.running?
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
						--env MYSQL_ROOT_PASSWORD=#{SmartMachine.credentials.mysql[:root_password]} \
						--env MYSQL_USER=#{SmartMachine.credentials.mysql[:username]} \
						--env MYSQL_PASSWORD=#{SmartMachine.credentials.mysql[:password]} \
						--env MYSQL_DATABASE=#{SmartMachine.credentials.mysql[:database_name]} \
						--user `id -u`:`id -g` \
						#{"--publish='#{SmartMachine.credentials.mysql[:port]}:#{SmartMachine.credentials.mysql[:port]}'" if exposed == '--exposed'} \
						--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/mysql/data:/var/lib/mysql' \
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
				if SmartMachine::Docker.running?
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