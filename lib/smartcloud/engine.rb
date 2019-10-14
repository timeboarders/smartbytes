# The main Smartcloud Engine driver
module Smartcloud
	class Engine < Smartcloud::Base
		def initialize
		end

		def self.install
		end

		def self.uninstall
		end

		def create_images
			# unless system("docker image inspect smartcloud", [:out, :err] => File::NULL)
			# 	print "-----> Creating image smartcloud ... "
			# 	if system("docker image build -t smartcloud \
			# 		--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
			# 		--build-arg USER_UID=`id -u` \
			# 		--build-arg USER_NAME=`id -un` \
			# 		#{Smartcloud.config.root_path}/lib/smartcloud/engine")
			# 		puts "done"
			# 	end
			# end

			#docker build -t smartcloud \
			#  --build-arg USER_UID=`id -u` \
			#  --build-arg USER_GID=`id -g` \
			#  --build-arg USER_NAME=`id -un` \
			#  .

			# docker run -it --rm -v "/home/$(whoami)/.smartcloud:/home/$(whoami)/.smartcloud" smartcloud
			#
			# system("docker create \
			# 	--name='smartcloud' \
			# 	--volume='#{Smartcloud.config.user_home_path}/.gem:#{Smartcloud.config.user_home_path}/.gem' \
			# 	--volume='#{Smartcloud.config.user_home_path}/.smartcloud/config:#{Smartcloud.config.user_home_path}/.smartcloud/config' \
			# 	--volume='#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner:#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-runner' \
			# 	--volume='/var/run/docker.sock:/var/run/docker.sock' \
			# 	--restart='always' \
			# 	--network='nginx-network' \
			# 	smartcloud/runner", out: File::NULL)
		end
	end
end