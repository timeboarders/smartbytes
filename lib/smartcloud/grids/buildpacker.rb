require 'open3'

module Smartcloud
	module Grids
		class Buildpacker < Smartcloud::Base
			def initialize
			end

			def pack
				set_logger_formatter_arrow

				pack_rails if File.exist? "bin/rails"

				logger.error "Could not continue ... Launch Failed."
				logger.formatter = nil
				exit 1
			end

			def pack_rails
				if File.exist? "tmp/smartcloud/packed"
					begin
						pid = File.read('tmp/smartcloud/packed').to_i
						Process.kill('QUIT', pid)
					rescue Errno::ESRCH # No such process
					end
					exec "bundle", "exec", "puma", "--config", "config/puma.rb"
				else
					return unless bundle_install?
					return unless precompile_assets?
					return unless test_web_server?

					exit 0
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
