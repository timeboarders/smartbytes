# The main SmartCloud Grids Minio driver
module SmartCloud
	module Grids
		class Nextcloud < SmartCloud::Base
			def initialize
			end

			def self.up
				if SmartCloud::Docker.running?
					# Creating & Starting containers
					print "-----> Creating container nextcloud ... "
					if system("docker create \
						--name='nextcloud' \
						--env VIRTUAL_HOST=#{SmartCloud.credentials.nextcloud[:hostname]}.#{SmartCloud.config.apps_domain} \
						--env LETSENCRYPT_HOST=#{SmartCloud.credentials.nextcloud[:hostname]}.#{SmartCloud.config.apps_domain} \
						--env LETSENCRYPT_EMAIL=#{SmartCloud.config.sysadmin_email} \
						--env LETSENCRYPT_TEST=false \
						--env NEXTCLOUD_TRUSTED_DOMAINS=#{SmartCloud.credentials.nextcloud[:hostname]}.#{SmartCloud.config.apps_domain} \
						--env NC_overwriteprotocol=https \
						--env NEXTCLOUD_ADMIN_USER=#{SmartCloud.credentials.nextcloud[:admin_username]} \
						--env NEXTCLOUD_ADMIN_PASSWORD=#{SmartCloud.credentials.nextcloud[:admin_password]} \
						--env MYSQL_HOST=#{SmartCloud.credentials.nextcloud[:database_host]}:#{SmartCloud.credentials.nextcloud[:database_port]} \
						--env MYSQL_USER=#{SmartCloud.credentials.nextcloud[:database_username]} \
						--env MYSQL_PASSWORD=#{SmartCloud.credentials.nextcloud[:database_password]} \
						--env MYSQL_DATABASE=#{SmartCloud.credentials.nextcloud[:database_name]} \
						--user `id -u`:`id -g` \
						--sysctl net.ipv4.ip_unprivileged_port_start=0 \
						--volume='#{SmartCloud.config.user_home_path}/.smartcloud/grids/nextcloud/html:/var/www/html' \
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
				if SmartCloud::Docker.running?
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