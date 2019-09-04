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
				# Remove server.pid if it exists
				FileUtils.rm("tmp/pids/server.pid") if File.exist? "tmp/pids/server.pid"

				# if system("god -c Godfile -D")
					return true
				# end
				# return false
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
