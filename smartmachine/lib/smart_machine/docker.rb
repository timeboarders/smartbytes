# The main SmartMachine Docker driver
module SmartMachine
	class Docker < SmartMachine::Base
		def initialize
		end

		# Installing Docker!
		#
		# Example:
		#   => Installation Complete
		#
		# Arguments:
		#   none
		def install
			puts "-----> Installing Docker"
			if OS.linux?
				install_on_linux(distro_name: "debian")
			elsif OS.mac?
				install_on_mac
			else
				puts "Installation of docker is currently supported on Debian or MacOS. Please install docker by other means on this platform to continue."
			end
			puts "-----> Docker Installation Complete"
		end

		# Uninstalling Docker!
		#
		# Example:
		#   => Uninstallation Complete
		#
		# Arguments:
		#   none
		def uninstall
			puts "-----> Uninstalling Docker"
			if OS.linux?
				uninstall_on_linux(distro_name: "debian")
			elsif OS.mac?
				uninstall_on_mac
			else
				puts "Uninstallation of docker is currently supported on Debian or MacOS. Please uninstall docker by other means on this platform to continue."
			end
			puts "-----> Docker Uninstallation Complete"
		end

		def self.running?
			if system("docker info", [:out, :err] => File::NULL)
				true
			else
				puts "Error: Docker daemon is not running. Have you installed docker? Please ensure docker daemon is running and try again."
				false
			end
		end

		private

		def install_on_linux(distro_name: "debian", arch: "amd64")
			commands = [
				"sudo apt-get -y update",
				"sudo apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common",
				"curl -fsSL https://download.docker.com/linux/#{distro_name}/gpg | sudo apt-key add -",
				"sudo apt-key fingerprint 0EBFCD88",
				"sudo add-apt-repository \"deb [arch=#{arch}] https://download.docker.com/linux/#{distro_name} $(lsb_release -cs) stable\"",
				"sudo apt-get -y update",
				"sudo apt-get -y install docker-ce docker-ce-cli containerd.io",
				"sudo usermod -aG docker $USER",
				"docker run --rm hello-world",
				"docker rmi hello-world"
			]
			run_based_on_machine_mode(commands: commands)

			puts '-----> Add the following rules to the end of the file /etc/ufw/after.rules and reload ufw using - sudo ufw reload'
			puts '# BEGIN UFW AND DOCKER
			*filter
			:ufw-user-forward - [0:0]
			:DOCKER-USER - [0:0]
			-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			-A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
			-A DOCKER-USER -i eth0 -j ufw-user-forward
			-A DOCKER-USER -i eth0 -j DROP
			COMMIT
			# END UFW AND DOCKER'

			# puts "-----> Adding UFW rules for Docker"
			# interface_name = system("ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/'")
			# puts interface_name

			# system("sed '/^# BEGIN UFW AND DOCKER/,/^# END UFW AND DOCKER/d' '/etc/ufw/after.rules'")
			# system("sudo tee -a '/etc/ufw/after.rules' > /dev/null <<EOT
			# # BEGIN UFW AND DOCKER
			# *filter
			# :ufw-user-forward - [0:0]
			# :DOCKER-USER - [0:0]
			# -A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			# -A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
			# -A DOCKER-USER -i eth0 -j ufw-user-forward
			# -A DOCKER-USER -i eth0 -j DROP
			# COMMIT
			# # END UFW AND DOCKER
			# EOT")
			# system("sudo ufw reload")
		end

		def uninstall_on_linux(distro_name: "debian", arch: "amd64")
			commands = [
				"sudo apt-get purge docker-ce docker-ce-cli containerd.io",
				"sudo rm -rf /var/lib/docker",
				"sudo rm -rf /var/lib/containerd"
			]
			run_based_on_machine_mode(commands: commands)

			puts '-----> Remove the following rules at the end of the file /etc/ufw/after.rules and reload ufw using - sudo ufw reload'
			puts '# BEGIN UFW AND DOCKER
			*filter
			:ufw-user-forward - [0:0]
			:DOCKER-USER - [0:0]
			-A DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
			-A DOCKER-USER -m conntrack --ctstate INVALID -j DROP
			-A DOCKER-USER -i eth0 -j ufw-user-forward
			-A DOCKER-USER -i eth0 -j DROP
			COMMIT
			# END UFW AND DOCKER'

			# puts "-----> Removing UFW rules for Docker"
			# system("sed '/^# BEGIN UFW AND DOCKER/,/^# END UFW AND DOCKER/d' '/etc/ufw/after.rules'")
			# system("sudo ufw reload")
		end

		def install_on_mac
			commands = [
				"/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\"",
				"brew install --cask docker",
				"brew install bash-completion",
				"brew install docker-completion",
				"open /Applications/Docker.app",
				# The docker app asks for permission after opening gui. if that can be automated then the next two statements can be uncommented and automated. Until then can't execute automatically.
				# "docker run --rm hello-world",
				# "docker rmi hello-world"
			]
			run_based_on_machine_mode(commands: commands)
		end

		def uninstall_on_mac
			commands = [
				"brew uninstall docker-completion",
				"brew uninstall bash-completion",
				"brew uninstall --cask --zap docker"
			]
			run_based_on_machine_mode(commands: commands)
		end

		def run_based_on_machine_mode(commands:)
			if SmartMachine.config.machine_mode == :server
				ssh = SmartMachine::SSH.new
				ssh.run commands
			else
				system(commands.join(";"))
			end
		end
	end
end