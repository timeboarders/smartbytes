# The main Smartcloud Engine driver
module Smartcloud
	class Engine < Smartcloud::Base
		def initialize
		end

		def self.install
			ssh = Smartcloud::SSH.new
			machine = Smartcloud::Machine.new

			system("mkdir -p ./tmp/engine")
			system("cp #{Smartcloud.config.root_path}/lib/smartcloud/engine/Dockerfile ./tmp/engine/Dockerfile")

			machine.sync first_sync: true

			puts "-----> Creating image smartcloud ... "
			ssh.run "docker image build -t smartcloud \
					--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
					--build-arg USER_UID=`id -u` \
					--build-arg USER_NAME=`id -un` \
					~/.smartcloud/tmp/engine"

			puts "-----> Adding smartcloud to PATH ... "
			ssh.run "chmod +x ~/.smartcloud/bin/smartcloud.sh && sudo ln -sf ~/.smartcloud/bin/smartcloud.sh /usr/local/bin/smartcloud"
			system("rm ./tmp/engine/Dockerfile")

			machine.sync
		end

		def self.uninstall
			ssh.run "sudo rm /usr/local/bin/smartcloud"
			ssh.run "docker rmi smartcloud"
		end
	end
end
