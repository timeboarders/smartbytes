# The main Smartcloud Grids Minio driver
module Smartcloud
	module Grids
		class Minio < Smartcloud::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if Smartcloud::Docker.running?
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
						--env MINIO_ACCESS_KEY=#{Smartcloud.credentials.minio[:access_key]} \
						--env MINIO_SECRET_KEY=#{Smartcloud.credentials.minio[:secret_key]} \
						--user `id -u`:`id -g` \
						#{"--publish='#{Smartcloud.credentials.minio[:port]}:#{Smartcloud.credentials.minio[:port]}'" if exposed == '--exposed'} \
						--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-minio/data:/data' \
						--restart='always' \
						--network='minio-network' \
						minio/minio:RELEASE.2020-02-27T00-23-05Z", out: File::NULL)

						puts "done"
						print "-----> Starting container minio ... "
						if system("docker start minio server /data", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
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