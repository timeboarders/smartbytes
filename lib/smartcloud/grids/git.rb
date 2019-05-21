# The main Smartcloud Grids Git driver
module Smartcloud
	module Grids
		class Git
			def initialize
			end

			def self.start
				if Smartcloud::Docker.running?
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

					# Creating images
					unless system("docker image inspect smartcloud/git-receive", [:out, :err] => File::NULL)
						print "-----> Creating image smartcloud/git-receive ... "
						if system("docker image build -t smartcloud/git-receive #{Smartcloud.root}/lib/smartcloud/grids/grid-git", out: File::NULL)
							puts "done"
						end
					end

					unless system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating image smartcloud/buildpacks/rails ... "
						if system("docker image build -t smartcloud/buildpacks/rails #{Smartcloud.root}/lib/smartcloud/grids/grid-git/buildpacks/rails", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					if system("docker image inspect smartcloud/git-receive", [:out, :err] => File::NULL) && system("docker image inspect smartcloud/buildpacks/rails", [:out, :err] => File::NULL)
						print "-----> Creating container git-receive ... "
						if system("docker create \
							--name='git-receive' \
							--env VIRTUAL_PROTO=fastcgi \
							--env VIRTUAL_HOST=#{self.virtual_host} \
							--env LETSENCRYPT_HOST=#{self.letsencrypt_host} \
							--env LETSENCRYPT_EMAIL=#{self.letsencrypt_email} \
							--env LETSENCRYPT_TEST=#{self.letsencrypt_test} \
							--expose='9000' \
							--volume='#{Smartcloud.user_home}/.smartcloud/apps:/apps' \
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

					# Removing swapfile
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
			end

			def self.virtual_host
				self.git_subdomain.nil? ? "git.#{Smartcloud.domain}" : "#{self.git_subdomain}.#{Smartcloud.domain}"
			end

			def self.letsencrypt_host
				self.virtual_host
			end

			def self.letsencrypt_email
				Smartcloud.admin_email
			end

			def self.letsencrypt_test
				Smartcloud.letsencrypt_test
			end

			def self.git_subdomain
				nil
			end
		end
	end
end