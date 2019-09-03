module Smartcloud
	class Buildpacker < Smartcloud::Base
		def initialize		
		end

		def pack
			pack_rails if File.exist? "bin/rails"
			logger.info "Could not continue ... Launch Failed."
		end

		def pack_rails
			# Remove server.pid if it exists
			FileUtils.rm("tmp/pids/server.pid") if File.exist? "tmp/pids/server.pid"

			logger.info "Performing bundle install ..."
			if system("bundle install --deployment --clean")
				logger.info "Installing Javascript Dependencies & Pre-compiling Assets ..."
				if system("bundle exec rails assets:precompile", out: File::NULL)
					logger.debug "Starting Server ..."
					if system("god -c Godfile -D")
						logger.info "Launched Application ... Success."
					end
					# exit 0
				end
			end
		end
	end
end
