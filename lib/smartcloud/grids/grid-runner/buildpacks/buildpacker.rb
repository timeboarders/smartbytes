class Buildpacker
	def initialize		
	end
	
	def pack
		puts "---------------------------------------------------------------------------"
		
		pack_rails if File.exist? "bin/rails"

		puts "-----> Could not continue ... Launch Failed."
	end

	def pack_rails
		# Remove server.pid if it exists
		FileUtils.rm("tmp/pids/server.pid") if File.exist? "tmp/pids/server.pid"

		puts "-----> Performing bundle install ... "
		if system("bundle check || bundle install")
			puts "-----> Installing Javascript Dependencies ... "
			if system("yarn install")
				puts "-----> Pre-compiling Assets ... "
				if system("bundle exec rails assets:precompile")
					puts "-----> Running Web Server ... "
					if system("foreman start -f Procfile")
						puts "-----> Launched Application ... Success."
					end
				end
			end
		end		
	end
end

buildpacker = Buildpacker.new
buildpacker.pack