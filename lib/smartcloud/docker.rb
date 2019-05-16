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
			system("sudo rm -rf /etc/docker/daemon.json")
			system("echo '{ \"iptables\": false }' | sudo tee -a /etc/docker/daemon.json > /dev/null")
			system("sudo systemctl restart docker")
			puts "-----> Installing Docker Compose"
			system("sudo curl -L --fail https://github.com/docker/compose/releases/download/1.21.2/run.sh -o /usr/local/bin/docker-compose")
			system("sudo chmod +x /usr/local/bin/docker-compose")
			system("docker-compose --version")
			system("sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose")
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
			puts "-----> Uninstalling Docker Compose"
			system("sudo rm /usr/local/bin/docker-compose")
			puts "-----> Uninstalling Docker"
			system("sudo apt-get purge docker-ce")
			system("sudo rm -rf /var/lib/docker")
			system("sudo rm -rf /etc/docker/daemon.json")
			puts "-----> Uninstallation Complete"
			puts "-----> You must delete any edited configuration files manually."
		end
	end
end