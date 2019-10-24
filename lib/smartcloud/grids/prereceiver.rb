# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Prereceiver < Smartcloud::Base

			def initialize
			end

			def self.up
				if Smartcloud::Docker.running?
					# Creating swapfile
					# self.create_swapfile

					# Creating images
					self.create_images

					# Creating & Starting containers
					if system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL) && system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating container prereceiver ... "
						if system("docker create \
							--name='prereceiver' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{Smartcloud.config.git_domain} \
							--env LETSENCRYPT_HOST=#{Smartcloud.config.git_domain} \
							--env LETSENCRYPT_EMAIL=#{Smartcloud.config.sysadmin_email} \
							--env LETSENCRYPT_TEST=#{Smartcloud.config.letsencrypt_test} \
							--env GIT_PROJECT_ROOT=#{Smartcloud.config.user_home_path}/.smartcloud/apps/repositories \
							--env GIT_HTTP_EXPORT_ALL="" \
							--user `id -u` \
							--workdir /home/`id -un`/.smartcloud/apps \
							--expose='9000' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/config:#{Smartcloud.config.user_home_path}/.smartcloud/config' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/apps:#{Smartcloud.config.user_home_path}/.smartcloud/apps' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-prereceiver:#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-prereceiver' \
							--volume='/var/run/docker.sock:/var/run/docker.sock:ro' \
							--restart='always' \
							--network='nginx-network' \
							smartcloud/prereceiver", out: File::NULL)
							puts "done"

							print "-----> Starting container prereceiver ... "
							if system("docker start prereceiver", out: File::NULL)
								puts "done"
							end
						end
					end
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					if system("docker inspect -f '{{.State.Running}}' 'prereceiver'", [:out, :err] => File::NULL)
						print "-----> Stopping container prereceiver ... "
						if system("docker stop 'prereceiver'", out: File::NULL)
							puts "done"

							print "-----> Removing container prereceiver ... "
							if system("docker rm 'prereceiver'", out: File::NULL)
								puts "done"
							end
						end
					else
						puts "-----> Container 'prereceiver' is currently not running."
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
				unless system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/prereceiver ... "
					if system("docker image build -t smartcloud/prereceiver \
						#{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-prereceiver", out: File::NULL)
						puts "done"
					end
				end

				unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/buildpacks/rails ... "
					if system("docker image build -t smartcloud/buildpacks/rails \
						--build-arg USER_UID=`id -u` \
						--build-arg USER_NAME=`id -un` \
						#{Smartcloud.config.root_path}/lib/smartcloud/engine/buildpacks/rails", out: File::NULL)
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

				if system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/prereceiver ... "
					if system("docker image rm smartcloud/prereceiver", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.prereceive(appname, username, oldrev, newrev, refname)
				logger.formatter = proc do |severity, datetime, progname, message|
					severity_text = { "DEBUG" => "\u{1f527} #{severity}:", "INFO" => " \u{276f}", "WARN" => "\u{2757} #{severity}:",
						"ERROR" => "\u{274c} #{severity}:", "FATAL" => "\u{2b55} #{severity}:", "UNKNOWN" => "\u{2753} #{severity}:"
					}
					"\t\t\t\t#{severity_text[severity]} #{message}\n"
				end

				# Load vars and environment
				container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/apps/containers/#{appname}"
				env_vars = Smartcloud::Apps::App.get_env_vars(container_path)
				return unless env_vars

				# Verify the user and ensure the user is correct and has access to this repository
				unless env_vars['USERNAME'] == username
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
							Smartcloud::Apps::App.start(appname)
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
		end
	end
end