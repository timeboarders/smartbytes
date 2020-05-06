# The main SmartCloud Grids Git driver
module SmartCloud
	module Grids
		class Prereceiver < SmartCloud::Base

			def initialize
			end

			def install
				self.uninstall
				unless system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/prereceiver ... "
					if system("docker image build -t smartcloud/prereceiver \
						#{SmartCloud.config.root_path}/lib/smartcloud/grids/prereceiver", out: File::NULL)
						puts "done"
					end
				end
			end

			def uninstall
				SmartCloud::Grids::Prereceiver.down
				if system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/prereceiver ... "
					if system("docker image rm smartcloud/prereceiver", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.up
				if SmartCloud::Docker.running?
					if system("docker image inspect smartcloud/prereceiver", [:out, :err] => File::NULL) && system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating container prereceiver ... "
						if system("docker create \
							--name='prereceiver' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{SmartCloud.config.git_domain} \
							--env LETSENCRYPT_HOST=#{SmartCloud.config.git_domain} \
							--env LETSENCRYPT_EMAIL=#{SmartCloud.config.sysadmin_email} \
							--env LETSENCRYPT_TEST=#{SmartCloud.config.letsencrypt_test} \
							--env GIT_PROJECT_ROOT=#{SmartCloud.config.user_home_path}/.smartcloud/apps/repositories \
							--env GIT_HTTP_EXPORT_ALL="" \
							--user `id -u` \
							--workdir /home/`id -un`/.smartcloud/apps \
							--expose='9000' \
							--volume='#{SmartCloud.config.user_home_path}/.smartcloud/config:#{SmartCloud.config.user_home_path}/.smartcloud/config' \
							--volume='#{SmartCloud.config.user_home_path}/.smartcloud/apps:#{SmartCloud.config.user_home_path}/.smartcloud/apps' \
							--volume='#{SmartCloud.config.user_home_path}/.smartcloud/grids/prereceiver:#{SmartCloud.config.user_home_path}/.smartcloud/grids/prereceiver' \
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
				if SmartCloud::Docker.running?
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
				container_path = "#{SmartCloud.config.user_home_path}/.smartcloud/apps/containers/#{appname}"
				env_vars = SmartCloud::Apps::App.get_env_vars(container_path)
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
							SmartCloud::Apps::App.start(appname)
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
		end
	end
end