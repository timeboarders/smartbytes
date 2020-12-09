# The main SmartMachine Engine driver
module SmartMachine
	class Engine < SmartMachine::Base
		def initialize
		end

		def install
			if SmartMachine::Docker.running?
				puts "-----> Installing SmartMachine Engine"

				# SmartMachine::User.create_htpasswd_files

				sync = SmartMachine::Sync.new

				system("mkdir -p ./tmp/engine")
				system("cp #{SmartMachine.config.gem_dir}/lib/smart_machine/engine/Dockerfile ./tmp/engine/Dockerfile")

				gem_file_path = "#{SmartMachine.config.cache_dir}/smartmachine-#{SmartMachine.version}.gem"
				system("cp #{gem_file_path} ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

				# sync.run only: :push

				print "-----> Creating image for Engine ... "
				docker_gid = (machine.has_linuxos? ? `getent group docker | cut -d: -f3` : (machine.has_macos? ? `id -g` : '')).to_i
				machine.run commands: "docker image build --quiet --tag #{engine_image_name_with_version} \
						--build-arg SMARTMACHINE_MASTER_KEY=#{SmartMachine::Credentials.new.read_key} \
						--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
						--build-arg USER_NAME=`id -un` \
						--build-arg USER_UID=`id -u` \
						--build-arg DOCKER_GID=#{docker_gid} \
						#{SmartMachine.config.machine_dir}/tmp/engine"
				puts "done"

				print "-----> Adding Engine to PATH ... "
				commands = [
					"mkdir -p #{SmartMachine.config.machine_dir}/bin && touch #{SmartMachine.config.machine_dir}/bin/smartengine",
					"echo '#{smartengine_binary_template}' > #{SmartMachine.config.machine_dir}/bin/smartengine",
					"chmod +x #{SmartMachine.config.machine_dir}/bin/smartengine",
					"sudo ln -sf #{SmartMachine.config.machine_dir}/bin/smartengine /usr/local/bin/smartengine"
				]
				machine.run(commands: commands)
				puts "done"

				system("rm ./tmp/engine/Dockerfile")
				system("rm ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

				# sync.run

				puts "-----> SmartMachine Engine Installation Complete"
			end
		end

		def uninstall
			if SmartMachine::Docker.running?
				puts "-----> Uninstalling SmartMachine Engine"

				commands = [
					"sudo rm /usr/local/bin/smartengine",
					"sudo rm #{SmartMachine.config.machine_dir}/bin/smartengine",
					"docker rmi $(docker images -q #{engine_image_name})"
				]
				machine.run(commands: commands)

				puts "-----> SmartMachine Engine Uninstallation Complete"
			end
		end

		private

		def machine
			@machine = SmartMachine::Machine.new
		end

		def smartengine_binary_template
			<<~BASH
				#!/bin/bash

				docker run -it --rm \
					-v "#{SmartMachine.config.machine_dir}:/home/`id -u`/machine" \
					-v "/var/run/docker.sock:/var/run/docker.sock" \
					-w "/home/`id -u`/machine" \
					-u `id -u` \
					--entrypoint "smartmachine" \
					#{engine_image_name_with_version} "$@"
			BASH
		end

		def engine_image_name_with_version
			"#{engine_image_name}:#{SmartMachine.version}"
		end

		def engine_image_name
			"smartmachine/smartengine"
		end
	end
end
