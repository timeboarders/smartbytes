# The main Smartcloud Apps Rails driver
module Smartcloud
	module Apps
		class Rails < Smartcloud::Base
			def initialize
			end

			def start(appname, container_path, container_path_with_version)
				return unless File.exist? "#{container_path_with_version}/bin/rails"

				logger.formatter = proc do |severity, datetime, progname, message|
					severity_text = { "DEBUG" => "\u{1f527} #{severity}:", "INFO" => " \u{276f}", "WARN" => "\u{2757} #{severity}:",
						"ERROR" => "\u{274c} #{severity}:", "FATAL" => "\u{2b55} #{severity}:", "UNKNOWN" => "\u{2753} #{severity}:"
					}
					"\t\t\t\t#{severity_text[severity]} #{message}\n"
				end

				logger.info "Ruby on Rails application detected."

				# Setup rails env
				env_path = "#{container_path}/env"
				system("grep -q '^## Rails' #{env_path} || echo '## Rails' >> #{env_path}")
				system("grep -q '^MALLOC_ARENA_MAX=' #{env_path} || echo '# MALLOC_ARENA_MAX=2' >> #{env_path}")
				system("grep -q '^RAILS_ENV=' #{env_path} || echo 'RAILS_ENV=production' >> #{env_path}")
				system("grep -q '^RACK_ENV=' #{env_path} || echo 'RACK_ENV=production' >> #{env_path}")
				system("grep -q '^RAILS_LOG_TO_STDOUT=' #{env_path} || echo 'RAILS_LOG_TO_STDOUT=enabled' >> #{env_path}")
				system("grep -q '^RAILS_SERVE_STATIC_FILES=' #{env_path} || echo 'RAILS_SERVE_STATIC_FILES=enabled' >> #{env_path}")
				system("grep -q '^LANG=' #{env_path} || echo 'LANG=en_US.UTF-8' >> #{env_path}")
				system("grep -q '^RAILS_MASTER_KEY=' #{env_path} || echo 'RAILS_MASTER_KEY=yourmasterkey' >> #{env_path}")
				logger.warn "Please set your RAILS_MASTER_KEY env var for this rails app." if system("grep -q '^RAILS_MASTER_KEY=yourmasterkey' #{env_path}")

				# Setup app folders needed for volumes. If this is not created then docker will create it while running the container,
				# but the folder will have root user assigned instead of the current user.
				FileUtils.mkdir_p("#{container_path}/app/vendor/bundle")
				FileUtils.mkdir_p("#{container_path}/app/public/assets")
				FileUtils.mkdir_p("#{container_path}/app/public/packs")
				FileUtils.mkdir_p("#{container_path}/app/node_modules")
				FileUtils.mkdir_p("#{container_path}/app/storage")
				FileUtils.mkdir_p("#{container_path_with_version}/vendor/bundle")
				FileUtils.mkdir_p("#{container_path_with_version}/public/assets")
				FileUtils.mkdir_p("#{container_path_with_version}/public/packs")
				FileUtils.mkdir_p("#{container_path_with_version}/node_modules")
				FileUtils.mkdir_p("#{container_path_with_version}/storage")

				# Creating & Starting container
				container_id = `docker ps -a -q --filter='name=^#{appname}_1$' --filter='status=running'`.chomp
				new_container = container_id.empty? ? "#{appname}_1" : "#{appname}_2"
				old_container = container_id.empty? ? "#{appname}_2" : "#{appname}_1"

				Smartcloud::Apps::App.stop("#{new_container}")
				if system("docker create \
					--name='#{new_container}' \
					--env-file='#{container_path}/env' \
					--user `id -u`:`id -g` \
					--workdir /app \
					--expose='3000' \
					--volume='#{Smartcloud.config.user_home_path}/.smartcloud/config:#{Smartcloud.config.user_home_path}/.smartcloud/config' \
					--volume='#{container_path_with_version}:/app' \
					--volume='#{container_path}/app/vendor/bundle:/app/vendor/bundle' \
					--volume='#{container_path}/app/public/assets:/app/public/assets' \
					--volume='#{container_path}/app/public/packs:/app/public/packs' \
					--volume='#{container_path}/app/node_modules:/app/node_modules' \
					--volume='#{container_path}/app/storage:/app/storage' \
					--restart='always' \
					--init \
					--network='nginx-network' \
					smartcloud/buildpacks/rails", out: File::NULL)

					system("docker network connect elasticsearch-network #{new_container}")
					system("docker network connect minio-network #{new_container}")
					system("docker network connect mysql-network #{new_container}")

					if system("docker start --attach #{new_container}")
						logger.debug "Starting Web Server ..."
						if system("docker start #{new_container}", out: File::NULL)
							sleep 7
							logger.info "Web Server started successfully."
							Smartcloud::Apps::App.stop(old_container)
							Smartcloud::Apps::App.clean_up(container_path)
							logger.info "Launched Application ... Success."
							exit 10
						end
					else
						Smartcloud::Apps::App.stop("#{new_container}")
					end
				end

				logger.formatter = nil
			end

			def pack
				set_logger_formatter_arrow

				if File.exist? "tmp/smartcloud/packed"
					begin
						pid = File.read('tmp/smartcloud/packed').to_i
						Process.kill('QUIT', pid)
					rescue Errno::ESRCH # No such process
					end
					exec "bundle", "exec", "puma", "--config", "config/puma.rb"
				else
					if initial_setup? && bundle_install? && precompile_assets? && db_migrate? && test_web_server?
						logger.formatter = nil

						exit 0
					else
						logger.error "Could not continue ... Launch Failed."
						logger.formatter = nil

						exit 1
					end
				end
			end

			private

			# Perform initial_setup
			def initial_setup?
				logger.info "Performing initial setup ..."

				exit_status = nil

				# Fix for mysql2 gem to support sha256_password, until it is fixed in main mysql2 gem.
				# https://github.com/brianmario/mysql2/issues/1023
				exit_status = system("mkdir -p ./lib/mariadb && ln -s /usr/lib/mariadb/plugin ./lib/mariadb/plugin")

				if exit_status
					return true
				else
					logger.error "Could not complete initial setup."
					return false
				end
			end

			# Perform bundle install
			def bundle_install?
				logger.info "Performing bundle install ..."

				set_logger_formatter_tabs
				exit_status = nil
				Open3.popen2e("bundle", "install", "--deployment", "--clean") do |stdin, stdout_and_stderr, wait_thr|
					stdout_and_stderr.each { |line| logger.info "#{line}" }
					exit_status = wait_thr.value.success?
				end
				set_logger_formatter_arrow

				if exit_status
					return true
				else
					logger.error "Could not complete bundle install."
					return false
				end
			end

			# Perform pre-compiling of assets
			def precompile_assets?
				logger.info "Installing Javascript dependencies & pre-compiling assets ..."

				set_logger_formatter_tabs
				exit_status = nil
				Open3.popen2e("bundle", "exec", "rails", "assets:precompile") do |stdin, stdout_and_stderr, wait_thr|
					stdout_and_stderr.each { |line| logger.info "#{line}" }
					exit_status = wait_thr.value.success?
				end
				set_logger_formatter_arrow

				if exit_status
					return true
				else
					logger.error "Could not install Javascript dependencies or pre-compile assets."
					return false
				end
			end

			# Perform db_migrate
			def db_migrate?
				return true # remove this line when you want to start using db_migrate?

				logger.info "Performing database migrations ..."

				set_logger_formatter_tabs
				exit_status = nil
				Open3.popen2e("bundle", "exec", "rails", "db:migrate") do |stdin, stdout_and_stderr, wait_thr|
					stdout_and_stderr.each { |line| logger.info "#{line}" }
					exit_status = wait_thr.value.success?
				end
				set_logger_formatter_arrow

				if exit_status
					return true
				else
					logger.error "Could not complete database migrations."
					return false
				end
			end

			# Perform testing of web server
			def test_web_server?
				logger.info "Setting up Web Server ..."

				# tmp folders
				FileUtils.mkdir_p("tmp/pids")
				FileUtils.mkdir_p("tmp/smartcloud")
				FileUtils.rm_f("tmp/smartcloud/packed")

				# Spawn Process
				pid = Process.spawn("bundle", "exec", "puma", "--config", "config/puma.rb", out: File::NULL)
				Process.detach(pid)

				# Sleep
				sleep 5

				# Check PID running
				status = nil
				begin
					Process.kill(0, pid)
					system("echo '#{pid}' > tmp/smartcloud/packed")
					status = true
				rescue Errno::ESRCH # No such process
					logger.info "Web Server could not start"
					status = false
				end

				# Return status
				return status
			end

			def set_logger_formatter_arrow
				logger.formatter = proc do |severity, datetime, progname, message|
					severity_text = { "DEBUG" => "\u{1f527} #{severity}:", "INFO" => " \u{276f}", "WARN" => "\u{2757} #{severity}:",
						"ERROR" => "\u{274c} #{severity}:", "FATAL" => "\u{2b55} #{severity}:", "UNKNOWN" => "\u{2753} #{severity}:"
					}
					"\t\t\t\t#{severity_text[severity]} #{message}\n"
				end
			end

			def set_logger_formatter_tabs
				logger.formatter = proc do |severity, datetime, progname, message|
					"\t\t\t\t       #{message}"
				end
			end
		end
	end
end