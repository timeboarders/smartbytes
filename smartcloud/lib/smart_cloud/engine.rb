# The main SmartCloud Engine driver
module SmartCloud
	class Engine < SmartCloud::Base
		def initialize
		end

		def install
			self.uninstall

			SmartCloud::User.create_htpasswd_files

			ssh = SmartCloud::SSH.new
			machine = SmartCloud::Machine.new

			system("mkdir -p ./tmp/engine")
			system("cp #{SmartCloud.config.root_path}/lib/smartcloud/engine/Dockerfile ./tmp/engine/Dockerfile")

			gem_file_path = File.expand_path("../../cache/smartcloud-#{SmartCloud.version}.gem", SmartCloud.config.root_path)
			system("cp #{gem_file_path} ./tmp/engine/smartcloud-#{SmartCloud.version}.gem")

			machine.sync first_sync: true

			puts "-----> Creating image smartcloud ... "
			ssh.run "docker image build -t smartcloud \
					--build-arg SMARTCLOUD_MASTER_KEY=#{SmartCloud::Credentials.new.read_key} \
					--build-arg SMARTCLOUD_VERSION=#{SmartCloud.version} \
					--build-arg USER_NAME=`id -un` \
					--build-arg USER_UID=`id -u` \
					--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
					~/.smartcloud/tmp/engine"

			puts "-----> Adding smartcloud to PATH ... "
			ssh.run "chmod +x ~/.smartcloud/bin/smartcloud.sh && sudo ln -sf ~/.smartcloud/bin/smartcloud.sh /usr/local/bin/smartcloud"
			system("rm ./tmp/engine/Dockerfile")
			system("rm ./tmp/engine/smartcloud-#{SmartCloud.version}.gem")

			machine.sync
		end

		def uninstall
			ssh = SmartCloud::SSH.new

			ssh.run "sudo rm /usr/local/bin/smartcloud"
			ssh.run "docker rmi smartcloud"
		end
	end
end
