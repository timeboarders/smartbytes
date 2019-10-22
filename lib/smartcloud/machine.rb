require "net/ssh"

# The main Smartcloud Machine driver
module Smartcloud
	class Machine < Smartcloud::Base
		def initialize
		end

		def create(*args)
			args.flatten!

			name = args.shift
			FileUtils.mkdir name
			FileUtils.cp_r "#{Smartcloud.config.root_path}/lib/smartcloud/templates/dotsmartcloud/.", "#{name}"
			puts "New machine #{name} has been created."
		end

		def start
			Smartcloud::User.create_htpasswd_files
			Smartcloud::Docker.install
			Smartcloud::Engine.install
		end

		def stop
			Smartcloud::Engine.uninstall
			Smartcloud::Docker.uninstall
		end

		def grid(*args)
			args.flatten!

			ssh = Smartcloud::SSH.new
			ssh.run "smartcloud run grid #{args.join(" ")}"
		end

		def ssh
			ssh = Smartcloud::SSH.new
			ssh.login
		end

		def run(*args)
			args.flatten!

			controller_type = args.shift.pluralize.capitalize
			controller_name = args.shift.capitalize
			controller = "Smartcloud::#{controller_type}::#{controller_name}"
			action = args.shift.to_sym

			args.empty? ? Object.const_get(controller).public_send(action) : Object.const_get(controller).public_send(action, args)

			# if ARGV[1] == 'runner'
			# 	if ARGV[2] == 'up'
			# 		Smartcloud::Grids::Runner.up
			# 	elsif ARGV[2] == 'down'
			# 		Smartcloud::Grids::Runner.down
			# 	end
			# elsif ARGV[1] == 'mysql'
			# 	if ARGV[2] == 'up'
			# 		Smartcloud::Grids::Mysql.up(ARGV[3])
			# 	elsif ARGV[2] == 'down'
			# 		Smartcloud::Grids::Mysql.down
			# 	end
			# elsif ARGV[1] == 'nginx'
			# 	if ARGV[2] == 'up'
			# 		Smartcloud::Grids::Nginx.up(ARGV[3])
			# 	elsif ARGV[2] == 'down'
			# 		Smartcloud::Grids::Nginx.down
			# 	end
			# elsif ARGV[1] == 'solr'
			# 	if ARGV[2] == 'up'
			# 		Smartcloud::Grids::Solr.up(ARGV[3])
			# 	elsif ARGV[2] == 'down'
			# 		Smartcloud::Grids::Solr.down
			# 	elsif ARGV[2] == 'create_core'
			# 		Smartcloud::Grids::Solr.create_core(ARGV[3])
			# 	elsif ARGV[2] == 'destroy_core'
			# 		Smartcloud::Grids::Solr.destroy_core(ARGV[3])
			# 	end
			# end
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

		def self.smartcloud_local?
			File.file?("./config/master.key")
		end

		def self.smartcloud_server?
			File.directory?("#{Smartcloud.config.user_home_path}/.smartcloud")
		end

		def sync(first_sync = false)
			puts "-----> Syncing smartcloud ... "
			return sync_push if first_sync

			unless block_given?
				sync_pull && sync_push
			else
				sync_pull
				yield
				sync_push
			end
		end

		private

		def sync_pull
			puts "-----> Sync pulling ... "
			system("rsync -azumv --delete --include=*/ --include={#{sync_pull_files_list}} --exclude=* -e ssh #{Smartcloud.credentials.machine[:username]}@#{Smartcloud.credentials.machine[:host]}:~/.smartcloud/ .")
		end

		def sync_push
			puts "-----> Sync pushing ... "
			system("rsync -azumv --delete --include=*/ --include={#{sync_push_files_list}} --exclude={#{excluded_sync_files_list}} --exclude={#{sync_pull_files_list}} -e ssh ./ #{Smartcloud.credentials.machine[:username]}@#{Smartcloud.credentials.machine[:host]}:~/.smartcloud")
		end

		def excluded_sync_files_list
			files = [
				'config/credentials.yml',
				'config/master.key',
				'config/users.yml'
			]
			files.join(',')
		end

		def sync_pull_files_list
			files = [
				'grids/grid-mysql/data/***',
				'grids/grid-nginx/certificates/***',
				'grids/grid-runner/apps/***',
				'grids/grid-solr/data/***',
			]
			files.join(',')
		end

		def sync_push_files_list
			files = [
				'grids/grid-mysql/data/.keep',
				'grids/grid-nginx/certificates/.keep',
				'grids/grid-runner/apps/containers/.keep',
				'grids/grid-runner/apps/repositories/.keep',
				'grids/grid-solr/data/.keep',
				'grids/grid-solr/data/README.txt',
				'grids/grid-solr/data/solr.xml',
				'grids/grid-solr/data/zoo.cfg',
				'grids/grid-solr/data/configsets/***',
				'grids/grid-solr/data/lib/***',
			]
			files.join(',')
		end
	end
end