# The main SmartCloud Grids Minio driver
module SmartCloud
	module Grids
		class Minio < SmartCloud::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartCloud::Docker.running?
					# Creating networks
					unless system("docker network inspect minio-network", [:out, :err] => File::NULL)
						print "-----> Creating network minio-network ... "
						if system("docker network create minio-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container minio ... "
					if system("docker create \
						--name='minio' \
						--env VIRTUAL_HOST=#{SmartCloud.credentials.minio[:hostname]}.#{SmartCloud.config.apps_domain} \
						--env LETSENCRYPT_HOST=#{SmartCloud.credentials.minio[:hostname]}.#{SmartCloud.config.apps_domain} \
						--env LETSENCRYPT_EMAIL=#{SmartCloud.config.sysadmin_email} \
						--env LETSENCRYPT_TEST=false \
						--env MINIO_ACCESS_KEY=#{SmartCloud.credentials.minio[:access_key]} \
						--env MINIO_SECRET_KEY=#{SmartCloud.credentials.minio[:secret_key]} \
						--env MINIO_BROWSER=#{SmartCloud.credentials.minio[:browser]} \
						--env MINIO_WORM=#{SmartCloud.credentials.minio[:worm]} \
						--user `id -u`:`id -g` \
						--volume='#{SmartCloud.config.user_home_path}/.smartcloud/grids/minio/data:/data' \
						--restart='always' \
						--network='minio-network' \
						minio/minio:RELEASE.2020-02-27T00-23-05Z server /data", out: File::NULL)

						# The alias is necessary to support internal network requests directed to minio container using public url
						system("docker network connect --alias #{SmartCloud.credentials.minio[:hostname]}.#{SmartCloud.config.apps_domain} minio-network nginx")
						system("docker network connect nginx-network minio")

						puts "done"
						print "-----> Starting container minio ... "
						if system("docker start minio", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def self.down
				if SmartCloud::Docker.running?
					# Disconnecting networks
					system("docker network disconnect nginx-network minio")
					system("docker network disconnect minio-network nginx")

					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container minio ... "
					if system("docker stop 'minio'", out: File::NULL)
						puts "done"
						print "-----> Removing container minio ... "
						if system("docker rm 'minio'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network minio-network ... "
					if system("docker network rm minio-network", out: File::NULL)
						puts "done"
					end
				end
			end
		end
	end
end