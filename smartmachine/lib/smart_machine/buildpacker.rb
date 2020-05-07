require 'open3'

module SmartMachine
	class Buildpacker < SmartMachine::Base
		def initialize
		end

		def install
			puts "-----> Installing Buildpacker"

			ssh = SmartMachine::SSH.new
			commands = ["smartmachine buildpacker create"]
			ssh.run commands

			puts "-----> Buildpacker Installation Complete"
		end

		def uninstall
			puts "-----> Uninstalling Buildpacker"

			ssh = SmartMachine::SSH.new
			commands = ["smartmachine buildpacker destroy"]
			ssh.run commands

			puts "-----> Buildpacker Uninstallation Complete"
		end

		def update
			self.uninstall
			self.install
		end

		def create
			self.destroy

			unless system("docker image inspect smartmachine/buildpacks/rails", [:out, :err] => File::NULL)
				print "-----> Creating image smartmachine/buildpacks/rails ... "
				if system("docker image build -t smartmachine/buildpacks/rails \
					--build-arg USER_UID=`id -u` \
					--build-arg USER_NAME=`id -un` \
					#{SmartMachine.config.root_path}/lib/smart_machine/engine/buildpacks/rails", out: File::NULL)
					puts "done"
				end
			end
		end

		def destroy
			if system("docker image inspect smartmachine/buildpacks/rails", [:out, :err] => File::NULL)
				print "-----> Removing image smartmachine/buildpacks/rails ... "
				if system("docker image rm smartmachine/buildpacks/rails", out: File::NULL)
					puts "done"
				end
			end
		end

		def pack
			if File.exist? "bin/rails"
				rails = SmartMachine::Apps::Rails.new
				rails.pack
			end
		end

		# These swapfile methods can be used (after required modification), when you need to make swapfile for more memory.
		# def self.create_swapfile
		# 	# Creating swapfile for bundler to work properly
		# 	unless system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
		# 		print "-----> Creating swap swapfile ... "
		# 		system("sudo install -o root -g root -m 0600 /dev/null /swapfile", out: File::NULL)
		# 		system("sudo dd if=/dev/zero of=/swapfile bs=1k count=2048k", [:out, :err] => File::NULL)
		# 		system("sudo mkswap /swapfile", out: File::NULL)
		# 		system("sudo sh -c 'echo \"/swapfile       none    swap    sw      0       0\" >> /etc/fstab'", out: File::NULL)
		# 		system("echo 10 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
		# 		system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
		# 		system("echo vm.swappiness = 10 | sudo tee -a /etc/sysctl.conf", out: File::NULL)
		# 		puts "done"
		#
		# 		print "-----> Starting swap swapfile ... "
		# 		if system("sudo swapon /swapfile", out: File::NULL)
		# 			puts "done"
		# 		end
		# 	end
		# end
		#
		# def self.destroy_swapfile
		# 	if system("sudo swapon -s | grep -ci '/swapfile'", out: File::NULL)
		# 		print "-----> Stopping swap swapfile ... "
		# 		if system("sudo swapoff /swapfile", out: File::NULL)
		# 			system("sudo sed -i '/^vm.swappiness = /d' /etc/sysctl.conf", out: File::NULL)
		# 			system("echo 60 | sudo tee /proc/sys/vm/swappiness", out: File::NULL)
		# 			puts "done"
		#
		# 			print "-----> Removing swap swapfile ... "
		# 			system("sudo sed -i '/^\\/swapfile/d' /etc/fstab", out: File::NULL)
		# 			if system("sudo rm /swapfile", out: File::NULL)
		# 				puts "done"
		# 			end
		# 		end
		# 	end
		# end
	end
end
