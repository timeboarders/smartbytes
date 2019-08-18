# The main Smartcloud Docker driver
module Smartcloud
	class Docker
		def initialize
		end

		# Installing Docker!
		#
		# Example:
		#   >> Docker.install
		#   => Installation Complete
		#
		# Arguments:
		#   none
		def self.install
			puts "-----> Installing Docker"
			system("sudo apt-get update")
			system("sudo apt-get install apt-transport-https ca-certificates curl software-properties-common")
			system("curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -")
			system("sudo apt-key fingerprint 0EBFCD88")
			system("sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"")
			system("sudo apt-get update")
			system("sudo apt-get install docker-ce")
			system("sudo usermod -aG docker $USER")
			system("docker run --rm hello-world")

			# puts "-----> Installing Docker Compose"
			# system("sudo curl -L --fail https://github.com/docker/compose/releases/download/1.24.0/run.sh -o /usr/local/bin/docker-compose")
			# system("sudo chmod +x /usr/local/bin/docker-compose")
			# system("docker-compose --version")
			# system("sudo curl -L https://raw.githubusercontent.com/docker/compose/1.24.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose")

			self.add_ufw_rules

			puts "-----> Installation Complete"
		end

		# Uninstalling Docker!
		#
		# Example:
		#   >> Docker.uninstall
		#   => Uninstallation Complete
		#
		# Arguments:
		#   none
		def self.uninstall
			# puts "-----> Uninstalling Docker Compose"
			# system("sudo rm /usr/local/bin/docker-compose")

			puts "-----> Uninstalling Docker"
			system("sudo apt-get purge docker-ce")
			system("sudo rm -rf /var/lib/docker")

			self.remove_ufw_rules

			puts "-----> Uninstallation Complete"
			puts "-----> You must delete any edited configuration files manually."
		end

		def self.running?
			if system("docker info", [:out, :err] => File::NULL)
				true
			else
				puts "Error: Docker daemon is not running. Have you installed docker? Please ensure docker daemon is running and try again."
				false
			end
		end

		def self.add_ufw_rules
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

		def self.remove_ufw_rules
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
	end
end