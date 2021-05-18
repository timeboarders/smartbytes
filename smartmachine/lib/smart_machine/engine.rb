# The main SmartMachine Engine driver
module SmartMachine
	class Engine < SmartMachine::Base
		def initialize
		end

		def install
			if SmartMachine::Docker.running?
				puts "-----> Installing SmartMachine Engine"

				# SmartMachine::Users.create_htpasswd_files

				syncer = SmartMachine::Syncer.new

				system("mkdir -p ./tmp/engine")
				system("cp #{SmartMachine.config.gem_dir}/lib/smart_machine/engine/Dockerfile ./tmp/engine/Dockerfile")

				gem_file_path = "#{SmartMachine.config.cache_dir}/smartmachine-#{SmartMachine.version}.gem"
				system("cp #{gem_file_path} ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

        syncer.sync only: :push

				print "-----> Creating image for Engine ... "
				docker_gid = machine_has_linuxos? ? "getent group docker | cut -d: -f3" : (machine_has_macos? ? "id -g" : "")
				docker_gname = machine_has_linuxos? ? "docker" : (machine_has_macos? ? "staff" : raise("OS not supported to create docker_gname"))
				run_commands_by_machine_mode commands: "docker image build --quiet --tag #{engine_image_name_with_version} \
						--build-arg SMARTMACHINE_MASTER_KEY=#{SmartMachine::Credentials.new.read_key} \
						--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
						--build-arg USER_NAME=`id -un` \
						--build-arg USER_UID=`id -u` \
						--build-arg DOCKER_GID=`#{docker_gid}` \
						--build-arg DOCKER_GNAME=#{docker_gname} \
						#{SmartMachine.config.machine_dir}/tmp/engine"
				puts "done"

				print "-----> Adding Engine to PATH ... "
				commands = [
					"mkdir -p #{SmartMachine.config.machine_dir}/bin && touch #{SmartMachine.config.machine_dir}/bin/smartengine",
					"echo '#{smartengine_binary_template}' > #{SmartMachine.config.machine_dir}/bin/smartengine",
					"chmod +x #{SmartMachine.config.machine_dir}/bin/smartengine",
					"sudo ln -sf #{SmartMachine.config.machine_dir}/bin/smartengine /usr/local/bin/smartengine"
				]
				run_commands_by_machine_mode(commands: commands)
				puts "done"

				system("rm ./tmp/engine/Dockerfile")
				system("rm ./tmp/engine/smartmachine-#{SmartMachine.version}.gem")

        syncer.sync

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
				run_commands_by_machine_mode(commands: commands)

				puts "-----> SmartMachine Engine Uninstallation Complete"
			end
		end

    def reinstall
      uninstall
      install
    end

		private

		def smartengine_binary_template
      docker_socket_path = "/var/run/docker.sock"
      docker_socket_path = "/Users/`whoami`/Library/Containers/com.docker.docker/Data/docker.sock" if machine_has_macos?

			<<~BASH
				#!/bin/bash

				docker run -it --rm \
          -e INSIDE_ENGINE="yes" \
					-v "#{SmartMachine.config.machine_dir}:/home/`whoami`/machine" \
					-v "#{docker_socket_path}:/var/run/docker.sock" \
					-w "/home/`whoami`/machine" \
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
