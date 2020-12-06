# The main SmartMachine Grids Git driver
module SmartMachine
	class Grids
		class Prereceiver < SmartMachine::Base

			def initialize
			end

			def install
				puts "-----> Installing Prereceiver"

				ssh = SmartMachine::SSH.new
				commands = ["smartmachine runner prereceiver create"]
				ssh.run commands

				puts "-----> Prereceiver Installation Complete"
			end

			def uninstall
				puts "-----> Uninstalling Prereceiver"

				ssh = SmartMachine::SSH.new
				commands = ["smartmachine runner prereceiver destroy"]
				ssh.run commands

				puts "-----> Prereceiver Uninstallation Complete"
			end

			def create
				unless system("docker image inspect #{prereceiver_image_name}", [:out, :err] => File::NULL)
					print "-----> Creating image #{prereceiver_image_name} ... "
					if system("docker image build -t #{prereceiver_image_name} \
									--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
									#{SmartMachine.config.root_path}/lib/smart_machine/grids/prereceiver", out: File::NULL)
						puts "done"

						up
					end
				end
			end

			def destroy
				down

				if system("docker image inspect #{prereceiver_image_name}", [:out, :err] => File::NULL)
					print "-----> Removing image #{prereceiver_image_name} ... "
					if system("docker image rm #{prereceiver_image_name}", out: File::NULL)
						puts "done"
					end
				end
			end

			def up
				if SmartMachine::Docker.running?
					if system("docker image inspect #{prereceiver_image_name}", [:out, :err] => File::NULL) && system("docker image inspect #{buildpacker_image_name}", [:out, :err] => File::NULL)
						print "-----> Creating container prereceiver with image #{prereceiver_image_name} ... "
						if system("docker create \
							--name='prereceiver' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{SmartMachine.config.git_domain} \
							--env LETSENCRYPT_HOST=#{SmartMachine.config.git_domain} \
							--env LETSENCRYPT_EMAIL=#{SmartMachine.config.sysadmin_email} \
							--env LETSENCRYPT_TEST=#{SmartMachine.config.letsencrypt_test} \
							--env GIT_PROJECT_ROOT=#{SmartMachine.config.user_home_path}/.smartmachine/apps/repositories \
							--env GIT_HTTP_EXPORT_ALL="" \
							--user `id -u` \
							--workdir /home/`id -un`/.smartmachine/apps \
							--expose='9000' \
							--volume='#{SmartMachine.config.user_home_path}/.smartmachine/config:#{SmartMachine.config.user_home_path}/.smartmachine/config' \
							--volume='#{SmartMachine.config.user_home_path}/.smartmachine/apps:#{SmartMachine.config.user_home_path}/.smartmachine/apps' \
							--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/prereceiver:#{SmartMachine.config.user_home_path}/.smartmachine/grids/prereceiver' \
							--volume='/var/run/docker.sock:/var/run/docker.sock:ro' \
							--restart='always' \
							--network='nginx-network' \
							#{prereceiver_image_name}", out: File::NULL)
							puts "done"

							print "-----> Starting container prereceiver with image #{prereceiver_image_name} ... "
							if system("docker start prereceiver", out: File::NULL)
								puts "done"
							end
						end
					end
				end
			end
	
			def down
				if SmartMachine::Docker.running?
					# Stopping & Removing containers - in reverse order
					if system("docker inspect -f '{{.State.Running}}' 'prereceiver'", [:out, :err] => File::NULL)
						print "-----> Stopping container prereceiver with image #{prereceiver_image_name} ... "
						if system("docker stop 'prereceiver'", out: File::NULL)
							puts "done"

							print "-----> Removing container prereceiver with image #{prereceiver_image_name} ... "
							if system("docker rm 'prereceiver'", out: File::NULL)
								puts "done"
							end
						end
					else
						puts "-----> Container 'prereceiver' is currently not running."
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
				container_path = "#{SmartMachine.config.user_home_path}/.smartmachine/apps/containers/#{appname}"
				env_vars = SmartMachine::Apps::App.get_env_vars(container_path)
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
							SmartMachine::Apps::App.start(appname)
						else
							logger.fatal "Could not extract new app version ... Failed."
							return
						end
					else
						logger.fatal "This version name already exists ... Failed."
						return
					end
				else
					# Allow the push to complete for all other branches normally.
					exit 10
				end

				logger.formatter = nil
			end

			def buildpacker_image_name
				Buildpacker.new.buildpacker_image_name
			end

			def prereceiver_image_name
				"smartmachine/prereceiver:#{SmartMachine.version}"
			end
		end
	end
end