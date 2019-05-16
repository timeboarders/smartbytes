# The main Smartcloud Docker driver
class Smartcloud::Docker
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
		# echo "-----> Installing Docker"
		# sudo apt-get update
		# sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
		# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		# sudo apt-key fingerprint 0EBFCD88
		# sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
		# sudo apt-get update
		# sudo apt-get install docker-ce
		# sudo usermod -aG docker $USER
		# docker run --rm hello-world
		# echo "-----> Installing Docker Compose"
		# sudo curl -L --fail https://github.com/docker/compose/releases/download/1.21.2/run.sh -o /usr/local/bin/docker-compose
		# sudo chmod +x /usr/local/bin/docker-compose
		# docker-compose --version
		# sudo curl -L https://raw.githubusercontent.com/docker/compose/1.21.2/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
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
		# echo "-----> Uninstalling Docker Compose"
		# sudo rm /usr/local/bin/docker-compose
		# echo "-----> Uninstalling Docker"
		# sudo apt-get purge docker-ce
		# sudo rm -rf /var/lib/docker
		puts "-----> Uninstallation Complete"
		puts "-----> You must delete any edited configuration files manually."
	end
end