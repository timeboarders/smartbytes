# The main SmartMachine Engine driver
module SmartMachine
	class Engine < SmartMachine::Base
		def initialize
		end

		def install
			puts "-----> Installing SmartMachine Engine"

			SmartMachine::User.create_htpasswd_files

			ssh = SmartMachine::SSH.new
			machine = SmartMachine::Machine.new
			sync = SmartMachine::Sync.new

			system("mkdir -p ./tmp/engine")
			system("cp #{SmartMachine.config.root_path}/lib/smart_machine/engine/Dockerfile ./tmp/engine/Dockerfile")

			gem_file_path = File.expand_path("../../cache/smartmachine-#{SmartMachine.version}.gem", SmartMachine.config.root_path)
			system("cp #{gem_file_path} ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

			sync.run only: :push

			print "-----> Creating image for SmartMachine ... "
			ssh.run "docker image build -t #{engine_image_name} \
					--build-arg SMARTMACHINE_MASTER_KEY=#{SmartMachine::Credentials.new.read_key} \
					--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
					--build-arg USER_NAME=`id -un` \
					--build-arg USER_UID=`id -u` \
					--build-arg DOCKER_GID=`getent group docker | cut -d: -f3` \
					~/.smartmachine/tmp/engine"
			puts "done"

			print "-----> Adding SmartMachine to PATH ... "
			ssh.run "chmod +x ~/.smartmachine/bin/smartmachine.sh && sudo ln -sf ~/.smartmachine/bin/smartmachine.sh /usr/local/bin/smartmachine"
			puts "done"

			system("rm ./tmp/engine/Dockerfile")
			system("rm ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

			sync.run

			puts "-----> SmartMachine Engine Installation Complete"
		end

		def uninstall
			puts "-----> Uninstalling SmartMachine Engine"

			ssh = SmartMachine::SSH.new

			ssh.run "sudo rm /usr/local/bin/smartmachine"
			ssh.run "docker rmi smartmachine"

			puts "-----> SmartMachine Engine Uninstallation Complete"
		end

		def update
			self.uninstall
			self.install
		end

		def engine_image_name
			"smartmachine:#{SmartMachine.version}"
		end
	end
end
