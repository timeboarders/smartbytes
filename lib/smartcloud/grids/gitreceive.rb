# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Gitreceive
			def initialize
			end

			def self.start
				if Smartcloud::Docker.running?
					# Creating swapfile
					# self.create_swapfile

					# Creating images
					self.create_images

					# Creating & Starting containers
					if system("docker image inspect smartcloud/git-receive", [:out, :err] => File::NULL) && system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating container git-receive ... "
						if system("docker create \
							--name='git-receive' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{Smartcloud.config.git_host} \
							--env LETSENCRYPT_HOST=#{Smartcloud.config.git_host} \
							--env LETSENCRYPT_EMAIL=#{Smartcloud.config.git_admin_email} \
							--env LETSENCRYPT_TEST=#{Smartcloud.config.git_letsencrypt_test} \
							--expose='9000' \
							--volume='#{Smartcloud.config.user_home_path}/.smartcloud/apps:/apps' \
							--volume='/var/run/docker.sock:/var/run/docker.sock' \
							--restart='always' \
							--network='nginx-network' \
							smartcloud/git-receive \
							spawn-fcgi -n -p 9000 /usr/bin/fcgiwrap -f", out: File::NULL)
							puts "done"

							print "-----> Starting container git-receive ... "
							if system("docker start git-receive", out: File::NULL)
								puts "done"
							end
						end
					end
				end
			end
	
			def self.stop
				if Smartcloud::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container git-receive ... "
					if system("docker stop 'git-receive'", out: File::NULL)
						puts "done"

						print "-----> Removing container git-receive ... "
						if system("docker rm 'git-receive'", out: File::NULL)
							puts "done"
						end
					end

					# Removing images
					# self.destroy_images

					# Removing swapfile
					# self.destroy_swapfile
				end
			end
			
			def self.create_swapfile
				# Creating swapfile for bundler to work properly
				unless system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
					print "-----> Creating swap swapfile ... "
					system("sudo install -o root -g root -m 0600 /dev/null /swapfile", out: File::NULL)
					system("sudo dd if=/dev/zero of=/swapfile bs=1k count=2048k", [:out, :err] => File::NULL)
					system("sudo mkswap /swapfile", out: File::NULL)
					system("sudo sh -c 'echo \"/swapfile       none    swap    sw      0       0\" >> /etc/fstab'", out: File::NULL)
					system("echo 10 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
					system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
					system("echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf", out: File::NULL)
					puts "done"

					print "-----> Starting swap swapfile ... "
					if system("sudo swapon /swapfile", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.destroy_swapfile
				if system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
					print "-----> Stopping swap swapfile ... "
					if system("sudo swapoff /swapfile", out: File::NULL)
						system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
						system("echo 60 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
						puts "done"

						print "-----> Removing swap swapfile ... "
						system("sudo sed -i '/^\\/swapfile/d' /etc/fstab", out: File::NULL)
						if system("sudo rm /swapfile", out: File::NULL)
							puts "done"
						end
					end
				end
			end
			
			def self.create_images
				unless system("docker image inspect smartcloud/git-receive", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/git-receive ... "
					if system("docker image build -t smartcloud/git-receive #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-gitreceive", out: File::NULL)
						puts "done"
					end
				end

				unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Creating image smartcloud/buildpacks/rails ... "
					if system("docker image build -t smartcloud/buildpacks/rails #{Smartcloud.config.root_path}/lib/smartcloud/grids/grid-gitreceive/buildpacks/rails", out: File::NULL)
						puts "done"
					end
				end
			end
			
			def self.destroy_images
				if system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/buildpacks/rails ... "
					if system("docker image rm smartcloud/buildpacks/rails", out: File::NULL)
						puts "done"
					end
				end

				if system("docker image inspect smartcloud/git-receive", [:out, :err] => File::NULL)
					print "-----> Removing image smartcloud/git-receive ... "
					if system("docker image rm smartcloud/git-receive", out: File::NULL)
						puts "done"
					end
				end
			end

			def self.prereceive(oldrev, newrev, refname)
				# Verify the user and ensure the user is correct and has access to this repository
				
				# # Only run this script for the master branch. You can remove this
				# # if block if you wish to run it for others as well.
				# if [ "$refname" == "refs/heads/master" ]; then
				#
				# 	echo "-----> Initializing Application"
				# 	if [ $(git rev-parse --is-bare-repository) = true ]; then
				# 	    REPOSITORY_BASENAME=$(basename "$PWD")
				# 		REPOSITORY_BASENAME=${REPOSITORY_BASENAME%.git}
				# 	else
				# 	    REPOSITORY_BASENAME=$(basename $(readlink -nf "$PWD"/..))
				# 	fi
				# 	REPOSITORY_PATH=/apps/containers/${REPOSITORY_BASENAME}
				# 	NOW_DATE=$(date +"%Y%m%d%H%M%S")
				# 	[[ ! -d "$REPOSITORY_PATH/$NOW_DATE" ]] && mkdir -p $REPOSITORY_PATH/$NOW_DATE && git archive "$newrev" | tar -x -C $REPOSITORY_PATH/$NOW_DATE
				#
				#
				# 	if [ -f $REPOSITORY_PATH/$NOW_DATE/bin/rails ]; then
				# 		echo "-----> Ruby on Rails Application Detected"
				#
				# 		if [ ! -f "$REPOSITORY_PATH/$NOW_DATE/Procfile" ]; then
				# 		echo "-----> Procfile not detected. Please add Procfile and try again."
				# 			exit 1;
				# 		fi
				#
				# 		if [ ! -f "$REPOSITORY_PATH/env" ]; then
				# 			echo "-----> Generating Environment Variables File"
				# 			cat > $REPOSITORY_PATH/env <<- EOF
				# 				##### Docker
				# 				VIRTUAL_HOST=$REPOSITORY_BASENAME.$DOMAIN_NAME
				# 				# LETSENCRYPT_HOST=$REPOSITORY_BASENAME.$DOMAIN_NAME
				# 				# LETSENCRYPT_EMAIL=admin@$DOMAIN_NAME
				# 				# LETSENCRYPT_TEST=true
				#
				# 				##### Rails
				# 				# RAILS_MASTER_KEY=testmasterkey
				# 			EOF
				# 		fi
				# 	fi
				#
				#
				# Smartcloud::Apps.start(name)
				# fi
			end
		end
	end
end