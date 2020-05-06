# The main Smartcloud Grids Redmine driver
module Smartcloud
	module Grids
		class Redmine < Smartcloud::Base
			def initialize
			end

			def self.up
				if Smartcloud::Docker.running?
					# Creating & Starting containers
					print "-----> Creating container redmine ... "
					if system("docker create \
						--name='redmine' \
						--env VIRTUAL_HOST=redmine.#{Smartcloud.config.apps_domain} \
						--env LETSENCRYPT_HOST=redmine.#{Smartcloud.config.apps_domain} \
						--env LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email} \
						--env LETSENCRYPT_TEST=false \
						--env REDMINE_SECRET_KEY_BASE=#{Smartcloud.credentials.redmine[:secret_key_base]} \
						--env REDMINE_DB_MYSQL=#{Smartcloud.credentials.redmine[:database_host]} \
						--env REDMINE_DB_PORT=#{Smartcloud.credentials.redmine[:database_port]} \
						--env REDMINE_DB_USERNAME=#{Smartcloud.credentials.redmine[:database_username]} \
						--env REDMINE_DB_PASSWORD=#{Smartcloud.credentials.redmine[:database_password]} \
						--env REDMINE_DB_DATABASE=#{Smartcloud.credentials.redmine[:database_name]} \
						--env REDMINE_PLUGINS_MIGRATE=#{Smartcloud.credentials.redmine[:plugins_migrate]} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/apps/repositories:/repositories:ro' \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-redmine/files:/usr/src/redmine/files' \
						--restart='always' \
						--network='nginx-network' \
						redmine:4.0.5-alpine", out: File::NULL)

						system("docker network connect mysql-network redmine")

						puts "done"
						print "-----> Starting container redmine ... "
						if system("docker start redmine", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container redmine ... "
					if system("docker stop 'redmine'", out: File::NULL)
						puts "done"
						print "-----> Removing container redmine ... "
						if system("docker rm 'redmine'", out: File::NULL)
							puts "done"
						end
					end
				end
			end			
		end
	end
end