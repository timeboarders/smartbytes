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
				FileUtils.mkdir_p("#{container_path}/app/public")
				FileUtils.mkdir_p("#{container_path}/app/node_modules")
				FileUtils.mkdir_p("#{container_path_with_version}/vendor/bundle")
				FileUtils.mkdir_p("#{container_path_with_version}/public")
				FileUtils.mkdir_p("#{container_path_with_version}/node_modules")

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
					--volume='#{container_path}/app/public:/app/public' \
					--volume='#{container_path}/app/node_modules:/app/node_modules' \
					--restart='always' \
					--init \
					--network='nginx-network' \
					smartcloud/buildpacks/rails", out: File::NULL)

					# system("docker network connect solr-network #{new_container}")
					system("docker network connect mysql-network #{new_container}")

					if system("docker start --attach #{new_container}")
						logger.debug "Starting Web Server ..."
						if system("docker start #{new_container}", out: File::NULL)
							sleep 5
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
		end
	end
end