require 'open3'

module Smartcloud
	class Buildpacker < Smartcloud::Base
		def initialize
		end

		def install
			self.uninstall
			unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
				print "-----> Creating image smartcloud/buildpacks/rails ... "
				if system("docker image build -t smartcloud/buildpacks/rails \
					--build-arg USER_UID=`id -u` \
					--build-arg USER_NAME=`id -un` \
					#{Smartcloud.config.root_path}/lib/smartcloud/engine/buildpacks/rails", out: File::NULL)
					puts "done"
				end
			end
		end

		def uninstall
			if system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
				print "-----> Removing image smartcloud/buildpacks/rails ... "
				if system("docker image rm smartcloud/buildpacks/rails", out: File::NULL)
					puts "done"
				end
			end
		end

		def pack
			if File.exist? "bin/rails"
				rails = Smartcloud::Apps::Rails.new
				rails.pack
			end
		end
	end
end
