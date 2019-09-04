# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Runner < Smartcloud::Base

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
							--restart='always' \
							--network='nginx-network' \
							smartcloud/runner", out: File::NULL)
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
						--build-arg USER_NAME=`id -un` \
						--build-arg USER_UID=`id -u` \
						--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
						#{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner", out: File::NULL)
						puts "done"
					end
				end

				unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/buildpacks/rails ... "
					if system("docker image build -t smartcloud/buildpacks/rails \
						--build-arg USER_UID=`id -u` \
						--build-arg USER_NAME=`id -un` \
						#{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-runner/buildpacks/rails", out: File::NULL)
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
					repository_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/repositories/#{appname}.git"
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/containers/#{appname}"
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
						%x[chmod +x #{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/pre-receive]
						%x[ln -s #{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/pre-receive #{repository_path}/hooks/pre-receive]
						puts "done"
					end

					# Creating Environment File
					if File.exist?("#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb")
						require "#{Smartcloud.config.user_home_path}/.smartcloud/config/environment"
					end
					unless File.exist? "#{container_path}/env"
						print "-----> Creating App Environment ... "
						page = <<~HEREDOC
							## System
							USERNAME=#{username}
							KEEP_RELEASES=3

							## Docker
							VIRTUAL_HOST=#{appname}.#{Smartcloud.config.apps_domain}
							LETSENCRYPT_HOST=#{appname}.#{Smartcloud.config.apps_domain}
							LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email}
							LETSENCRYPT_TEST=false
						HEREDOC
						puts "done" if system("echo '#{page}' > #{container_path}/env")
					end
				end
			end

			def self.destroy_app(appname)
				if Smartcloud::Docker.running?
					# Stopping & Removing old container
					self.stop_app(appname)

					# Destroying Directories
					print "-----> Deleting App #{appname} ... "
					repository_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/repositories/#{appname}.git"
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/containers/#{appname}"
					FileUtils.rm_r(repository_path)
					FileUtils.rm_r(container_path)
					puts "done"
				end
			end

			def self.prereceive_app(appname, username, oldrev, newrev, refname)
				logger.formatter = proc do |severity, datetime, progname, message|
					severity_text = { "DEBUG" => "\u{1f527} #{severity}:", "INFO" => " \u{276f}", "WARN" => "\u{2757} #{severity}:",
						"ERROR" => "\u{274c} #{severity}:", "FATAL" => "\u{2b55} #{severity}:", "UNKNOWN" => "\u{2753} #{severity}:"
					}
					"\t\t\t\t#{severity_text[severity]} #{message}\n"
				end

				# Load vars and environment
				container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/containers/#{appname}"
				return unless self.load_container_env_vars(container_path)

				# Verify the user and ensure the user is correct and has access to this repository
				unless ENV['USERNAME'] == username
					logger.error "Unauthorized."
					return
				end

				# Only run this script for the master branch. You can remove this
				# if block if you wish to run it for others as well.
				if refname == "refs/heads/master"
					logger.info "Loading Application ..."

					# Note: There should be no space between + and " in version.
					# Note: date will be UTC date until timezone has been changed.
					version = `date +"%Y%m%d%H%M%S"`.chomp!
					container_path_with_version = "#{container_path}/releases/#{version}"

					unless Dir.exist? container_path_with_version
						FileUtils.mkdir_p(container_path_with_version)
						if system("git archive #{newrev} | tar -x -C #{container_path_with_version}")
							# Start App
							self.start_app(appname)
						else
							logger.fatal "Could not extract new app version ... Failed."
							return
						end
					else
						logger.fatal "This version name already exists ... Failed."
						return
					end
				end

				logger.formatter = nil
			end

			def self.start_app(appname, app_version = 0)
				if Smartcloud::Docker.running?
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner/apps/containers/#{appname}"

					Dir.chdir("#{container_path}/releases") do
						# Getting App Version
						if app_version == 0
							app_versions = Dir.glob('*').select { |f| File.directory? f }.sort
							app_version = app_versions.last
						end
						container_path_with_version = "#{container_path}/releases/#{app_version}"

						# Launching Application
						logger.info "Launching Application ..."
						if File.exist? "#{container_path_with_version}/bin/rails"
							# Starting Rails App
							self.start_app_rails(appname, container_path, container_path_with_version)
						end
					end
				end
			end

			def self.stop_app(appname)
				if Smartcloud::Docker.running?
					if system("docker inspect -f '{{.State.Running}}' #{appname}", [:out, :err] => File::NULL)
						logger.debug "Stopping container #{appname} ..."
						if system("docker stop '#{appname}'", out: File::NULL)
							logger.debug "Removing container #{appname} ..."
							if system("docker rm '#{appname}'", out: File::NULL)
								logger.debug "Stopped & Removed #{appname} ..."
							end
						end
					end
				end
			end

			def self.start_app_rails(appname, container_path, container_path_with_version)
				# Stopping & Removing not required app containers
				# TODO: To be removed after dynamic container switching has been implemented as it should be done in the end at the time of cleanup after the new container is running.
				self.stop_app(appname)

				logger.info "Ruby on Rails application detected."

				# Setup rails env
				env_path = "#{container_path}/env"
				system("grep -q '^## Rails' #{env_path} || echo '## Rails' >> #{env_path}")
				system("grep -q '^RAILS_ENV=' #{env_path} || echo 'RAILS_ENV=production' >> #{env_path}")
				system("grep -q '^RACK_ENV=' #{env_path} || echo 'RACK_ENV=production' >> #{env_path}")
				system("grep -q '^RAILS_LOG_TO_STDOUT=' #{env_path} || echo 'RAILS_LOG_TO_STDOUT=enabled' >> #{env_path}")
				system("grep -q '^RAILS_SERVE_STATIC_FILES=' #{env_path} || echo 'RAILS_SERVE_STATIC_FILES=enabled' >> #{env_path}")
				system("grep -q '^LANG=' #{env_path} || echo 'LANG=en_US.UTF-8' >> #{env_path}")
				system("grep -q '^RAILS_MASTER_KEY=' #{env_path} || echo 'RAILS_MASTER_KEY=yourmasterkey' >> #{env_path}")
				logger.warn "WARNING: Please set your RAILS_MASTER_KEY env var for this rails app." if system("grep -q '^RAILS_MASTER_KEY=yourmasterkey' #{env_path}")

				# Setup gems folder. If this is not created then docker will create it while running the container,
				# but the folder will have root user assigned instead of the current user.
				FileUtils.mkdir_p("#{container_path}/gems")

				# Setup Godfile
				unless File.exist? "#{container_path_with_version}/Godfile"
					logger.warn "WARNING: Godfile not detected. Adding a default Godfile. It is recommended to add your own Godfile."
					page = <<~"HEREDOC"
						God.watch do |w|
							w.name = "web"
							w.start = "bundle exec puma -C config/puma.rb"
							w.behavior(:clean_pid_file)
							w.keepalive
						end
					HEREDOC
					system("echo '#{page}' > #{container_path_with_version}/Godfile")
				end

				# Creating & Starting container
				if system("docker create \
					--name='#{appname}' \
					--env-file='#{container_path}/env' \
					--expose='5000' \
					--volume='#{container_path_with_version}:/code' \
					--volume='#{container_path}/gems:/code/vendor/bundle' \
					--workdir='/code' \
					--restart='always' \
					--network='nginx-network' \
					smartcloud/buildpacks/rails", out: File::NULL)

					system("docker network connect solr-network #{appname}")
					system("docker network connect mysql-network #{appname}")

					system("docker start --attach #{appname}")
					self.clean_up(container_path)
				end
			end

			def self.clean_up(container_path)
				logger.info "Cleaning up ..."

				# Stopping & Removing not required app containers
				appname = File.basename(container_path)
				self.stop_app(appname)

				# Clean up very old versions
				Dir.chdir("#{container_path}/releases") do
					app_versions = Dir.glob('*').select { |f| File.directory? f }.sort
					destroy_count = app_versions.count - ENV['KEEP_RELEASES'].to_i
					if destroy_count > 0
						logger.debug "Deleting older application releases ..."
						destroy_count.times do
							FileUtils.rm_r(File.join(Dir.pwd, app_versions.shift))
						end
					end
				end
			end

			def self.load_container_env_vars(container_path)
				unless File.exist? "#{container_path}/env"
					logger.fatal "Environment could not be loaded ... Failed."
					return false
				end

				File.open("#{container_path}/env").each_line do |line|
					line.chomp!
					next if line.empty? || line.start_with?('#')
				    key, value = line.split "="
				    ENV[key] = value
				end

				true
			end
		end
	end
end