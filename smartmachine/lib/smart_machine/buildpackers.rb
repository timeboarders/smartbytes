require 'open3'

module SmartMachine
	class Buildpackers < SmartMachine::Base
		def initialize
		end

    def run(args)
      command = args.shift

      if command == "install"
        install
      elsif command == "uninstall"
        uninstall
      else
        raise "invalid command on buildpackers"
      end
    end

		def install
			puts "-----> Installing Buildpackers"
      create_images
			puts "-----> Buildpackers Installation Complete"
		end

		def uninstall
			puts "-----> Uninstalling Buildpackers"
      destroy_images
			puts "-----> Buildpackers Uninstallation Complete"
		end

		def pack
			if File.exist? "bin/rails"
				rails = SmartMachine::Apps::Rails.new
				rails.pack
			end
		end

		def buildpacker_image_name
			"smartmachine/buildpackers/rails:#{SmartMachine.version}"
		end

    private

		def create_images
			unless system("docker image inspect #{buildpacker_image_name}", [:out, :err] => File::NULL)
				print "-----> Creating image #{buildpacker_image_name} ... "
				if system("docker image build -t #{buildpacker_image_name} \
					--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
					--build-arg USER_UID=`id -u` \
					--build-arg USER_NAME=`id -un` \
					#{SmartMachine.config.root_path}/lib/smart_machine/buildpackers/rails", out: File::NULL)
					puts "done"
				end
			end
		end

		def destroy_images
			if system("docker image inspect #{buildpacker_image_name}", [:out, :err] => File::NULL)
				print "-----> Removing image #{buildpacker_image_name} ... "
				if system("docker image rm #{buildpacker_image_name}", out: File::NULL)
					puts "done"
				end
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
