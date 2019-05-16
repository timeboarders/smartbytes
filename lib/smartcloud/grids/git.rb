# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Git
			def initialize
			end
	
			def self.start
				# if ! $(free | awk '/^Swap:/ {exit !$2}'); then
				# 	echo "-----> Adding Swap for bundler to work properly"
				# 	sudo swapon -s
				# 	sudo dd if=/dev/zero of=/swapfile bs=1024 count=256k
				# 	sudo mkswap /swapfile
				# 	sudo chmod 0600 /swapfile
				# 	sudo swapon /swapfile
				# 	sudo sh -c 'echo "/swapfile       none    swap    sw      0       0" >> /etc/fstab'
				# 	echo 10 | sudo tee /proc/sys/vm/swappiness
				# 	echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf
				# 	sudo chown root:root /swapfile
				# fi
				#
				# if [[ "$(sudo docker images -q tbcloud/git-receive 2> /dev/null)" == "" ]]; then
				# 	echo "-----> Building Image with Git Receive Essentials"
				# 	docker image build -t tbcloud/git-receive .
				# fi
				#
				# if [[ "$(sudo docker images -q tbcloud/ruby-2.5.1 2> /dev/null)" == "" ]]; then
				# 	echo "-----> Building Image with Ruby on Rails Essentials"
				# 	docker image build -t tbcloud/ruby-2.5.1 ./buildpacks/rails-pack/.
				# fi
				#
				# if [[ "$(sudo docker images -q tbcloud/git-receive 2> /dev/null)" != "" && "$(sudo docker images -q tbcloud/ruby-2.5.1 2> /dev/null)" != "" ]]; then
				# 	echo "-----> Starting Git Network"
				# 	cp ../.env .env
				# 	docker-compose up -d
				# 	rm .env
				# fi
			end
	
			def self.stop
				# echo "-----> Stopping Git Network"
				# cp ../.env .env
				# docker-compose down
				# rm .env
			end

			def self.docker_compose_filepath
				File.join(Smartcloud.root, 'lib/smartcloud/grids/grid-git/docker-compose.yml')
			end
		end
	end
end