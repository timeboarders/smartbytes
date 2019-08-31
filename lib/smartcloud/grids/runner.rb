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
							--env GIT_PROJECT_ROOT=#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/repositories \
							--env GIT_HTTP_EXPORT_ALL="" \
							--expose='9000' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/config:#{Smartcloud.config.user_home_path}/.smartcloud/config' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner:#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner' \
							--volume='/var/run/docker.sock:/var/run/docker.sock' \
							--user=#{File.basename(Smartcloud.config.user_home_path)} \
							--workdir='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps' \
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
					if system("docker inspect -f '{{.State.Running}}' 'runner'", [:out, :err] => File::NULL)
						print "-----> Stopping container runner ... "
						if system("docker stop 'runner'", out: File::NULL)
							puts "done"

							print "-----> Removing container runner ... "
							if system("docker rm 'runner'", out: File::NULL)
								puts "done"
							end
						end
					else
						puts "-----> Container 'runner' is currently not running."
					end

					# Removing images
					self.destroy_images

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
					if system("docker image build -t smartcloud/runner \
						--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
						--build-arg USER_UID=`id -u` \
						--build-arg USER_NAME=`id -un` \
						#{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner", out: File::NULL)
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
			#   appname => (String)
			# 	username => (String)
			def self.create_app(appname, username)
				if Smartcloud::Docker.running?
					repository_path = "/.smartcloud/grids/grid-runner/apps/repositories/#{appname}.git"
					container_path = "/.smartcloud/grids/grid-runner/apps/containers/#{appname}"
					print "-----> Creating Application ... "

					# Checking if app with given name already exists
					if Dir.exist?(repository_path)
						puts "failed. App with name '#{appname}' already exists."
						exit
					end

					# Creating Directories
					FileUtils.mkdir_p(repository_path)
					FileUtils.mkdir_p(container_path)

					# Initializing bare repo and pre-receive
					Dir.chdir(repository_path) do
						%x[git init --bare]
						%x[chmod +x /.smartcloud/grids/grid-runner/pre-receive]
						%x[ln -s /.smartcloud/grids/grid-runner/pre-receive #{repository_path}/hooks/pre-receive]
						puts "done"
					end

					# Creating Environment File
					if File.exist?("/.smartcloud/config/environment.rb")
						require "/.smartcloud/config/environment"
					end
					unless File.exist? "#{container_path}/env"
						print "-----> Creating App Environment ... "
						system("cat > #{container_path}/env <<- EOF
							## System
							USERNAME=#{username}
							KEEP_RELEASES=3

							## Docker
							VIRTUAL_HOST=#{appname}.#{Smartcloud.config.apps_domain}
							LETSENCRYPT_HOST=#{appname}.#{Smartcloud.config.apps_domain}
							LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email}
							LETSENCRYPT_TEST=false
						EOF")
						puts "done"
					end
				end
			end

			def self.prereceive_app(appname, username, oldrev, newrev, refname)
				container_path = "/.smartcloud/grids/grid-runner/apps/containers/#{appname}"

				## Verify the user and ensure the user is correct and has access to this repository
				print "-----> Verifying User ... "
				unless File.exist? "#{container_path}/env"
					puts "Environment could not be loaded ... Failed"
					exit 1
				end

				# Load ENV vars
				File.open("#{container_path}/env").each_line do |line|
					line.chomp!
					next if line.empty? || line.start_with?('#')
				    key, value = line.split "="
				    ENV[key] = value
				end

				# Match Username
				unless ENV['USERNAME'] == username
					puts "User is not authorized ... Failed"
					exit 1
				end
				puts "done"

				# Only run this script for the master branch. You can remove this
				# if block if you wish to run it for others as well.
				if refname == "refs/heads/master"
					print "-----> Initializing Application ... "

					# Note: There should be no space between + and " in now_date.
					# Note: date will be UTC date until timezone has been changed.
					now_date = `date +"%Y%m%d%H%M%S"`.chomp!
					container_path_with_now_date = "#{container_path}/#{now_date}"

					unless Dir.exist? container_path_with_now_date
						FileUtils.mkdir_p(container_path_with_now_date)
						if system("git archive #{newrev} | tar -x -C #{container_path_with_now_date}")
							puts "done"

							# Clean up very old versions
							Dir.chdir(container_path) do
								app_versions = Dir.glob('*').select { |f| File.directory? f }.sort
								destroy_count = app_versions.count - ENV['KEEP_RELEASES'].to_i
								if destroy_count > 0
									print "-----> Deleting Old Application Versions ... "
									destroy_count.times do
										FileUtils.rm_r(File.join(Dir.pwd, app_versions.shift))
									end
									puts "done"
								end
							end

							# Start App
							Dir.chdir(container_path_with_now_date) do
								# self.start_app(appname)
							end
						else
							puts "failed. Could not extract new app version."
							exit 1
						end
					end
				end
			end
		
			def self.stop_app(username, name)
				if Smartcloud::Docker.running?
				end
			end

			def self.stop_app(appname)
				if Smartcloud::Docker.running?
					print "-----> Stopping container #{appname} ... "
					if system("docker stop '#{appname}'", out: File::NULL)
						puts "done"

						print "-----> Removing container #{appname} ... "
						if system("docker rm '#{appname}'", out: File::NULL)
							puts "done"
						end
					end
				end
			end

			def self.destroy_app(appname)
				if Smartcloud::Docker.running?
					# Stopping & Removing old container
					self.stop_app(appname)

					# Destroying Directories
					print "-----> Deleting App #{appname} ... "
					repository_path = "/.smartcloud/grids/grid-runner/apps/repositories/#{appname}.git"
					container_path = "/.smartcloud/grids/grid-runner/apps/containers/#{appname}"
					FileUtils.rm_r(repository_path)
					FileUtils.rm_r(container_path)
					puts "done"
				end
			end
		end
	end
end