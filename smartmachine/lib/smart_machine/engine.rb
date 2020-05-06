# The main SmartMachine Engine driver
module SmartMachine
	class Engine < SmartMachine::Base
		def initialize
		end

		def install
			self.uninstall

			SmartMachine::User.create_htpasswd_files

			ssh = SmartMachine::SSH.new
			machine = SmartMachine::Machine.new

			system("mkdir -p ./tmp/engine")
			system("cp #{SmartMachine.config.root_path}/lib/smartmachine/engine/Dockerfile ./tmp/engine/Dockerfile")

			gem_file_path = File.expand_path("../../cache/smartmachine-#{SmartMachine.version}.gem", SmartMachine.config.root_path)
			system("cp #{gem_file_path} ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

			machine.sync first_sync: true

			puts "-----> Creating image smartmachine ... "
			ssh.run "docker image build -t smartmachine \
					--build-arg SMARTMACHINE_MASTER_KEY=#{SmartMachine::Credentials.new.read_key} \
					--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
					--build-arg USER_NAME=`id -un` \
					--build-arg USER_UID=`id -u` \
					--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
					~/.smartmachine/tmp/engine"

			puts "-----> Adding smartmachine to PATH ... "
			ssh.run "chmod +x ~/.smartmachine/bin/smartmachine.sh && sudo ln -sf ~/.smartmachine/bin/smartmachine.sh /usr/local/bin/smartmachine"
			system("rm ./tmp/engine/Dockerfile")
			system("rm ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

			machine.sync
		end

		def uninstall
			ssh = SmartMachine::SSH.new

			ssh.run "sudo rm /usr/local/bin/smartmachine"
			ssh.run "docker rmi smartmachine"
		end
	end
end
