require "net/ssh"

# The main SmartMachine Machine driver
module SmartMachine
	class Machine < SmartMachine::Base
		def initialize
		end

		# Create a new smartmachine
		#
		# Example:
		#   >> Machine.create("QW21334Q")
		#   => "New machine QW21334Q has been created."
		#
		# Arguments:
		#   name: (String)
		def create(name)
			raise "Please specify a machine name" if name.blank?

			pathname = File.expand_path "./#{name}"

			if Dir.exist?(pathname)
				puts "A machine with this name already exists. Please use a different name."
				return
			end

			FileUtils.mkdir pathname
			FileUtils.cp_r "#{SmartMachine.config.root_path}/lib/smart_machine/templates/dotsmartmachine/.", pathname
			FileUtils.chdir pathname do
				credentials = SmartMachine::Credentials.new
				credentials.create
				system("git init && git add . && git commit -m 'initial commit'")
			end

			puts "New machine #{name} has been created."
		end

		def ssh
			if SmartMachine.config.machine_mode == :server
				ssh = SmartMachine::SSH.new
				ssh.login
			else
				puts "Help: Cannot ssh into local machine. You can only use the ssh command when using smartmachine for a server."
			end
		end

		def installer(*args)
			args.flatten!

			action = args.shift

			if args.empty? || args.include?("docker")
				docker = SmartMachine::Docker.new
				docker.public_send(action)
			end

			if args.empty? || args.include?("engine")
				engine = SmartMachine::Engine.new
				engine.public_send(action)
			end

			if args.empty? || args.include?("buildpacker")
				buildpacker = SmartMachine::Buildpacker.new
				buildpacker.public_send(action)
			end

			if args.empty? || args.include?("prereceiver")
				prereceiver = SmartMachine::Grids::Prereceiver.new
				prereceiver.public_send(action)
			end

			if args.empty? || args.include?("scheduler")
				scheduler = SmartMachine::Grids::Scheduler.new
				scheduler.public_send(action)
			end

			if args.empty? || args.include?("elasticsearch")
				elasticsearch = SmartMachine::Grids::Elasticsearch.new
				elasticsearch.public_send(action)
			end
		end

		def grids(*args)
			args.flatten!

			if args.delete("--local")
				exec "smartmachine runner grids #{args.join(" ")}"
			else
				ssh = SmartMachine::SSH.new
				ssh.run "smartmachine runner grids #{args.join(" ")}"
			end
		end

		def apps(*args)
			args.flatten!

			if args.delete("--local")
				exec "smartmachine runner apps #{args.join(" ")}"
			else
				ssh = SmartMachine::SSH.new
				ssh.run "smartmachine runner apps #{args.join(" ")}"
			end
		end

		def ps(*args)
			args.flatten!

			if args.delete("--local")
				exec "docker ps #{args.join(' ')}"
			else
				ssh = SmartMachine::SSH.new
				ssh.run "docker ps #{args.join(' ')}"
			end
		end

		def logs(*args)
			args.flatten!

			if args.delete("--local")
				exec "docker logs #{args.join(' ')}"
			else
				ssh = SmartMachine::SSH.new
				ssh.run "docker logs #{args.join(' ')}"
			end
		end

		def getting_started
			# puts 'You may be prompted to make a menu selection when the Grub package is updated on Ubuntu. If prompted, select keep the local version currently installed.'

			# apt-get update && apt-get upgrade

			# hostnamectl set-hostname example_hostname

			# /etc/hosts
			# 127.0.0.1 localhost.localdomain localhost
			# 203.0.113.10 hostname.example.com hostname
			# 2600:3c01::a123:b456:c789:d012 hostname.example.com hostname
			# Add DNS records for IPv4 and IPv6 for ip addresses and their fully qualified domain names FQDN

			# dpkg-reconfigure tzdata
			# date
		end

		def securing_your_server
			# sudo apt install unattended-upgrades

			# sudo nano /etc/apt/apt.conf.d/20auto-upgrades
			# APT::Periodic::Update-Package-Lists "1";
			# APT::Periodic::Download-Upgradeable-Packages "1";
			# APT::Periodic::AutocleanInterval "7";
			# APT::Periodic::Unattended-Upgrade "1";

			# sudo apt install apticron
			# /etc/apticron/apticron.conf
			# EMAIL="root@example.com"

			# adduser example_user
			# adduser example_user sudo

			# mkdir -p ~/.ssh && sudo chmod -R 700 ~/.ssh/
			# scp ~/.ssh/id_rsa.pub example_user@203.0.113.10:~/.ssh/authorized_keys
			# sudo chmod -R 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys

			# sudo nano /etc/ssh/sshd_config
			# PermitRootLogin no
			# PasswordAuthentication no
			# echo 'AddressFamily inet' | sudo tee -a /etc/ssh/sshd_config
			# sudo systemctl restart sshd

			# sudo apt-get update && sudo apt-get upgrade -y
			# sudo apt-get install fail2ban
			# sudo apt-get install sendmail
			# sudo ufw allow ssh
			# sudo ufw enable
			# sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
			# sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
			# Change destmail, sendername, sender
			# Change action = %(action_mwl)s
			# sudo fail2ban-client reload
			# sudo fail2ban-client status
		end

		def in_machine_dir?
			File.file?("./config/master.key")
		end
	end
end