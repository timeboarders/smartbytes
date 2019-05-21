# The main Smartcloud Grids Nginx driver
module Smartcloud
	module Grids
		class Nginx
			def initialize
			end
	
			def self.start
				if self.docker_running?
					# Creating volumes
					print "-----> Creating volume nginx-confd ... "
					if system("docker volume create nginx-confd", out: File::NULL)
						puts "done"
					end

					print "-----> Creating volume nginx-vhost ... "
					if system("docker volume create nginx-vhost", out: File::NULL)
						puts "done"
					end

					print "-----> Creating volume nginx-shtml ... "
					if system("docker volume create nginx-shtml", out: File::NULL)
						puts "done"
					end

					# Creating networks
					unless system("docker network inspect nginx-network", [:out, :err] => File::NULL)
						print "-----> Creating network nginx-network ... "
						if system("docker network create nginx-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container nginx ... "
					if system("docker create \
						--name='nginx' \
						--publish='80:80' \
						--publish='443:443' \
						--volume='nginx-confd:/etc/nginx/conf.d/' \
						--volume='nginx-vhost:/etc/nginx/vhost.d/' \
						--volume='nginx-shtml:/usr/share/nginx/html' \
						--volume='#{Smartcloud.root}/lib/smartcloud/grids/grid-nginx/fastcgi.conf:/etc/nginx/fastcgi.conf:ro' \
						--volume='#{Smartcloud.user_home}/.smartcloud/grids/grid-nginx/certificates:/etc/nginx/certs:ro' \
						--volume='#{Smartcloud.user_home}/.smartcloud/grids/grid-nginx/logins:/etc/nginx/htpasswd:ro' \
						--restart='always' \
						--network='nginx-network' \
						nginx", out: File::NULL)

						puts "done"
						print "-----> Starting container nginx ... "
						if system("docker start nginx", out: File::NULL)
							puts "done"
						end
					end

					print "-----> Creating container nginx-gen ... "
					if system("docker create \
						--name='nginx-gen' \
						--volume='nginx-confd:/etc/nginx/conf.d/' \
						--volume='nginx-vhost:/etc/nginx/vhost.d/' \
						--volume='nginx-shtml:/usr/share/nginx/html' \
						--volume='#{Smartcloud.root}/lib/smartcloud/grids/grid-nginx/fastcgi.conf:/etc/nginx/fastcgi.conf:ro' \
						--volume='#{Smartcloud.root}/lib/smartcloud/grids/grid-nginx/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro' \
						--volume='#{Smartcloud.user_home}/.smartcloud/grids/grid-nginx/certificates:/etc/nginx/certs:ro' \
						--volume='#{Smartcloud.user_home}/.smartcloud/grids/grid-nginx/logins:/etc/nginx/htpasswd:ro' \
						--volume='/var/run/docker.sock:/tmp/docker.sock:ro' \
						--restart='always' \
						--network='nginx-network' \
						jwilder/docker-gen \
						-notify-sighup nginx -watch /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf", out: File::NULL)

						puts "done"
						print "-----> Starting container nginx-gen ... "
						if system("docker start nginx-gen", out: File::NULL)
							puts "done"
						end
					end

					print "-----> Creating container nginx-letsencrypt ... "
					if system("docker create \
						--name='nginx-letsencrypt' \
						--env NGINX_PROXY_CONTAINER=nginx \
						--env NGINX_DOCKER_GEN_CONTAINER=nginx-gen \
						--volume='nginx-confd:/etc/nginx/conf.d/' \
						--volume='nginx-vhost:/etc/nginx/vhost.d/' \
						--volume='nginx-shtml:/usr/share/nginx/html' \
						--volume='#{Smartcloud.user_home}/.smartcloud/grids/grid-nginx/certificates:/etc/nginx/certs:rw' \
						--volume='/var/run/docker.sock:/var/run/docker.sock:ro' \
						--restart='always' \
						--network='nginx-network' \
						jrcs/letsencrypt-nginx-proxy-companion", out: File::NULL)

						puts "done"
						print "-----> Starting container nginx-letsencrypt ... "
						if system("docker start nginx-letsencrypt", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def self.stop
				if self.docker_running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container nginx-letsencrypt ... "
					if system("docker stop 'nginx-letsencrypt'", out: File::NULL)
						puts "done"
						print "-----> Removing container nginx-letsencrypt ... "
						if system("docker rm 'nginx-letsencrypt'", out: File::NULL)
							puts "done"
						end
					end

					print "-----> Stopping container nginx-gen ... "
					if system("docker stop 'nginx-gen'", out: File::NULL)
						puts "done"
						print "-----> Removing container nginx-gen ... "
						if system("docker rm 'nginx-gen'", out: File::NULL)
							puts "done"
						end
					end

					print "-----> Stopping container nginx ... "
					if system("docker stop 'nginx'", out: File::NULL)
						puts "done"
						print "-----> Removing container nginx ... "
						if system("docker rm 'nginx'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network nginx-network ... "
					if system("docker network rm nginx-network", out: File::NULL)
						puts "done"
					end
				end
			end
	
			def self.docker_running?
				if system("docker info", out: File::NULL)
					true
				else
					puts "Error: Docker daemon is not running. Have you installed docker? Please ensure docker daemon is running and try again."
					false
				end
			end
		end
	end
end
