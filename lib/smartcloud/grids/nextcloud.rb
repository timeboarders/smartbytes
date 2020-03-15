# The main Smartcloud Grids Minio driver
module Smartcloud
	module Grids
		class Nextcloud < Smartcloud::Base
			def initialize
			end

			def self.up
				if Smartcloud::Docker.running?
					# Creating & Starting containers
					print "-----> Creating container nextcloud ... "
					if system("docker create \
						--name='nextcloud' \
						--env VIRTUAL_HOST=#{Smartcloud.credentials.nextcloud[:hostname]}.#{Smartcloud.config.apps_domain} \
						--env LETSENCRYPT_HOST=#{Smartcloud.credentials.nextcloud[:hostname]}.#{Smartcloud.config.apps_domain} \
						--env LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email} \
						--env LETSENCRYPT_TEST=false \
						--env NEXTCLOUD_TRUSTED_DOMAINS=#{Smartcloud.credentials.nextcloud[:hostname]}.#{Smartcloud.config.apps_domain} \
						--env NEXTCLOUD_ADMIN_USER=#{Smartcloud.credentials.nextcloud[:admin_username]} \
						--env NEXTCLOUD_ADMIN_PASSWORD=#{Smartcloud.credentials.nextcloud[:admin_password]} \
						--env MYSQL_HOST=#{Smartcloud.credentials.nextcloud[:database_host]}:#{Smartcloud.credentials.nextcloud[:database_port]} \
						--env MYSQL_USER=#{Smartcloud.credentials.nextcloud[:database_username]} \
						--env MYSQL_PASSWORD=#{Smartcloud.credentials.nextcloud[:database_password]} \
						--env MYSQL_DATABASE=#{Smartcloud.credentials.nextcloud[:database_name]} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-nextcloud/html:/var/www/html' \
						--restart='always' \
						--network='nginx-network' \
						nextcloud:18.0.2-apache", out: File::NULL)

						system("docker network connect mysql-network nextcloud")

						puts "done"
						print "-----> Starting container nextcloud ... "
						if system("docker start nextcloud", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container nextcloud ... "
					if system("docker stop 'nextcloud'", out: File::NULL)
						puts "done"
						print "-----> Removing container nextcloud ... "
						if system("docker rm 'nextcloud'", out: File::NULL)
							puts "done"
						end
					end
				end
			end
		end
	end
end