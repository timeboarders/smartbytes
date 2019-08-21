# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Runner
			def initialize
			end

			def self.up
				if Smartcloud::Docker.running?
					# Creating swapfile
					# self.create_swapfile

					# Creating images
					self.create_images

					# Creating & Starting containers
					if system("docker image inspect smartcloud/runner", [:out, :err] => File::NULL) && system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating container runner ... "
						if system("docker create \
							--name='runner' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{Smartcloud.config.git_domain} \
							--env LETSENCRYPT_HOST=#{Smartcloud.config.git_domain} \
							--env LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email} \
							--env LETSENCRYPT_TEST=#{Smartcloud.config.letsencrypt_test} \
							--expose='9000' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/config:/.smartcloud/config' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner:/.smartcloud/grids/grid-runner' \
							--volume='/var/run/docker.sock:/var/run/docker.sock' \
							--restart='always' \
							--network='nginx-network' \
							smartcloud/runner \
							spawn-fcgi -n -p 9000 /usr/bin/fcgiwrap -f", out: File::NULL)
							puts "done"

							print "-----> Starting container runner ... "
							if system("docker start runner", out: File::NULL)
								puts "done"
							end
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container runner ... "
					if system("docker stop 'runner'", out: File::NULL)
						puts "done"

						print "-----> Removing container runner ... "
						if system("docker rm 'runner'", out: File::NULL)
							puts "done"
						end
					end

					# Removing images
					# self.destroy_images

					# Removing swapfile
					# self.destroy_swapfile
				end
			end
			
			def self.create_swapfile
				# Creating swapfile for bundler to work properly
				unless system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
					print "-----> Creating swap swapfile ... "
					system("sudo install -o root -g root -m 0600 /dev/null /swapfile", out: File::NULL)
					system("sudo dd if=/dev/zero of=/swapfile bs=1k count=2048k", [:out, :err] => File::NULL)
					system("sudo mkswap /swapfile", out: File::NULL)
					system("sudo sh -c 'echo \"/swapfile       none    swap    sw      0       0\" >> /etc/fstab'", out: File::NULL)
					system("echo 10 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
					system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
					system("echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf", out: File::NULL)
					puts "done"

					print "-----> Starting swap swapfile ... "
					if system("sudo swapon /swapfile", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.destroy_swapfile
				if system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
					print "-----> Stopping swap swapfile ... "
					if system("sudo swapoff /swapfile", out: File::NULL)
						system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
						system("echo 60 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
						puts "done"

						print "-----> Removing swap swapfile ... "
						system("sudo sed -i '/^\\/swapfile/d' /etc/fstab", out: File::NULL)
						if system("sudo rm /swapfile", out: File::NULL)
							puts "done"
						end
					end
				end
			end
			
			def self.create_images
				unless system("docker image inspect smartcloud/runner", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/runner ... "
					if system("docker image build -t smartcloud/runner #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner", out: File::NULL)
						puts "done"
					end
				end

				unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/buildpacks/rails ... "
					if system("docker image build -t smartcloud/buildpacks/rails #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner/buildpacks/rails", out: File::NULL)
						puts "done"
					end
				end
			end
			
			def self.destroy_images
				if system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/buildpacks/rails ... "
					if system("docker image rm smartcloud/buildpacks/rails", out: File::NULL)
						puts "done"
					end
				end

				if system("docker image inspect smartcloud/runner", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/runner ... "
					if system("docker image rm smartcloud/runner", out: File::NULL)
						puts "done"
					end
				end
			end

			# Creating App!
			#
			# Example:
			#   >> Apps.create
			#   => Creation Complete
			#
			# Arguments:
			# 	username => (String)
			#   name => (String)
			def self.create_app(username, name)
				if Smartcloud::Docker.running?
					repo_path = "/.smartcloud/grids/grid-runner/apps/repositories/#{username}/#{name}.git"

					print "-----> Creating Application ... "

					if Dir.exist?(repo_path)
						puts "failed. App with name '#{name}' already exists."
						exit
					end

					Dir.mkdir(repo_path)

					Dir.chdir(repo_path) do
						%x[git init --bare]
						%x[chmod +x #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner/pre-receive]
						%x[ln -s #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner/pre-receive #{repo_path}/hooks/pre-receive]
						puts "done"
					end
				end
			end

			# Running App!
			#
			# Example:
			#   >> Apps.run
			#   => Running Complete
			#
			# Arguments:
			# 	username => (String)
			#   name => (String)		
			def self.start_app(username, name)
				if Smartcloud::Docker.running?
					# 	echo "-----> Launching Application"
					# 	if [ "$(docker ps -a -q -f name=$REPOSITORY_BASENAME)" ]; then
					# 		docker stop "$REPOSITORY_BASENAME" && docker rm "$REPOSITORY_BASENAME"
					# 	fi
					# 	docker create \
					# 		--log-opt mode=non-blocking --log-opt max-buffer-size=4m \
					# 		--name="$REPOSITORY_BASENAME" \
					# 		--env-file="$REPOSITORY_PATH/env" \
					# 		--volume="$APPS_ROOT/containers/$REPOSITORY_BASENAME/$NOW_DATE:/code" \
					# 		--volume="~/.smartcloud/grid-runner/buildpacks/rails/gems:/.gems" \
					# 		--network="nginx-network" \
					# 		--expose="5000" \
					# 		--restart="always" \
					# 		smartcloud/buildpacks/rails
					# 	docker network connect solr-network $REPOSITORY_BASENAME
					# 	docker start $REPOSITORY_BASENAME
					# 	docker logs $REPOSITORY_BASENAME --follow
				end
			end
		
			def self.stop_app(username, name)
				if Smartcloud::Docker.running?
				end
			end
		
			def self.restart_app(username, name)
				if Smartcloud::Docker.running?
				end
			end

			# Destroying App!
			#
			# Example:
			#   >> Apps.destroy
			#   => Destruction Complete
			#
			# Arguments:
			# 	username => (String)
			#   name => (String)
			def self.destroy_app(username, name)
				if Smartcloud::Docker.running?
				end
			end
		end
	end
end