# The main SmartMachine Grids Minio driver
module SmartMachine
	class Grids
		class Minio < SmartMachine::Base
			def initialize
			end

			def up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartMachine::Docker.running?
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
						--env VIRTUAL_HOST=#{SmartMachine.credentials.minio[:name]}.#{SmartMachine.config.apps_domain} \
						--env LETSENCRYPT_HOST=#{SmartMachine.credentials.minio[:name]}.#{SmartMachine.config.apps_domain} \
						--env LETSENCRYPT_EMAIL=#{SmartMachine.config.sysadmin_email} \
						--env LETSENCRYPT_TEST=false \
						--env MINIO_ACCESS_KEY=#{SmartMachine.credentials.minio[:access_key]} \
						--env MINIO_SECRET_KEY=#{SmartMachine.credentials.minio[:secret_key]} \
						--env MINIO_BROWSER=#{SmartMachine.credentials.minio[:browser]} \
						--env MINIO_WORM=#{SmartMachine.credentials.minio[:worm]} \
						--user `id -u`:`id -g` \
						--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/minio/data:/data' \
						--restart='always' \
						--network='minio-network' \
						minio/minio:RELEASE.2020-02-27T00-23-05Z server /data", out: File::NULL)

						# The alias is necessary to support internal network requests directed to minio container using public url
						system("docker network connect --alias #{SmartMachine.credentials.minio[:name]}.#{SmartMachine.config.apps_domain} minio-network nginx")
						system("docker network connect nginx-network minio")

						puts "done"
						print "-----> Starting container minio ... "
						if system("docker start minio", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def down
				if SmartMachine::Docker.running?
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