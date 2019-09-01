class Buildpacker
	def initialize		
	end
	
	def pack
		pack_rails if File.exist? "bin/rails"
		puts "-----> Could not continue ... Launch Failed."
	end

	def pack_rails
		# Remove server.pid if it exists
		FileUtils.rm("tmp/pids/server.pid") if File.exist? "tmp/pids/server.pid"

		puts "-----> Performing bundle install ... "
		if system("bundle install --deployment --clean --without development test")
			puts "-----> Installing Javascript Dependencies & Pre-compiling Assets ... "
			if system("bundle exec rails assets:precompile", out: File::NULL)
				puts "done"

				puts "-----> Running Web Server ... "
				if system("god -c Godfile -D")
					puts "-----> Launched Application ... Success."
				end
				exit 0
			end
		end		
	end
end

buildpacker = Buildpacker.new
buildpacker.pack