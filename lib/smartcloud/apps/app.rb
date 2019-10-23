# The main Smartcloud App driver
module Smartcloud
	module Apps
		class App < Smartcloud::Base
			def initialize
			end

			# Creating App!
			#
			# Example:
			#   >> Smartcloud::Apps::Rails.create
			#   => Creation Complete
			#
			# Arguments:
			#   appname => (String)
			# 	username => (String)
			def self.create(*args)
				args.flatten!
				appname = args.empty? ? '' : args.shift
				username = args.empty? ? '' : args.shift

				raise "Please provide appname and username" if appname.empty? || username.empty?

				if Smartcloud::Docker.running?
					repository_path = "#{Smartcloud.config.user_home_path}/.smartcloud/apps/repositories/#{appname}.git"
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/apps/containers/#{appname}"
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

			def self.destroy(*args)
				args.flatten!
				appname = args.empty? ? '' : args.shift

				raise "Please provide appname" if appname.empty?

				if Smartcloud::Docker.running?
					# Stopping & Removing old container
					self.stop(appname)

					# Destroying Directories
					print "-----> Deleting App #{appname} ... "
					repository_path = "#{Smartcloud.config.user_home_path}/.smartcloud/apps/repositories/#{appname}.git"
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/apps/containers/#{appname}"
					FileUtils.rm_r(repository_path)
					FileUtils.rm_r(container_path)
					puts "done"
				end
			end
			
			def self.start(*args)
				args.flatten!
				appname = args.empty? ? '' : args.shift
				app_version = args.empty? ? 0 : args.shift.to_i

				raise "Please provide appname" if appname.empty?

				if Smartcloud::Docker.running?
					container_path = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/apps/containers/#{appname}"

					Dir.chdir("#{container_path}/releases") do
						# Getting App Version
						if app_version == 0
							app_versions = Dir.glob('*').select { |f| File.directory? f }.sort
							app_version = app_versions.last
						end
						container_path_with_version = "#{container_path}/releases/#{app_version}"

						logger.info "Launching Application ..."

						app = Smartcloud::Apps::Rails.new
						app.start(appname, container_path, container_path_with_version)
					end
				end
			end

			def self.stop(*args)
				args.flatten!
				appname = args.empty? ? '' : args.shift

				raise "Please provide appname" if appname.empty?

				container_name = appname

				if Smartcloud::Docker.running?
					container_id = `docker ps -a -q --filter='name=^#{container_name}$'`.chomp
					unless container_id.empty?
						logger.debug "Stopping & Removing container #{container_name} ..."
						if system("docker stop #{container_name} && docker rm #{container_name}", out: File::NULL)
							logger.debug "Stopped & Removed container #{container_name} ..."
						end
					else
						logger.debug "Container '#{container_name}' does not exist to stop."
					end
				end
			end

			def self.clean_up(container_path)
				env_vars = Smartcloud::Apps::App.get_env_vars(container_path)
				return unless env_vars

				logger.info "Cleaning up ..."

				# Clean up very old versions
				Dir.chdir("#{container_path}/releases") do
					app_versions = Dir.glob('*').select { |f| File.directory? f }.sort
					destroy_count = app_versions.count - env_vars['KEEP_RELEASES'].to_i
					if destroy_count > 0
						logger.debug "Deleting older application releases ..."
						destroy_count.times do
							FileUtils.rm_r(File.join(Dir.pwd, app_versions.shift))
						end
					end
				end
			end

			def self.get_env_vars(container_path)
				unless File.exist? "#{container_path}/env"
					logger.fatal "Environment could not be loaded ... Failed."
					return false
				end

				env_vars = {}
				File.open("#{container_path}/env").each_line do |line|
					line.chomp!
					next if line.empty? || line.start_with?('#')
				    key, value = line.split "="
				    env_vars[key] = value
				end

				env_vars
			end
		end
	end
end