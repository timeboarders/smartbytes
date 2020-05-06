require "net/ssh"

# The main SmartMachine Machine driver
module SmartMachine
	class Machine < SmartMachine::Base
		def initialize
		end

		def create(*args)
			args.flatten!

			name = args.shift
			FileUtils.mkdir name
			FileUtils.cp_r "#{SmartMachine.config.root_path}/lib/smartmachine/templates/dotsmartmachine/.", "#{name}"
			FileUtils.chdir "#{name}" do
				credentials = SmartMachine::Credentials.new
				credentials.create
			end
			puts "New machine #{name} has been created."
		end

		def start
			SmartMachine::Docker.install

			engine = SmartMachine::Engine.new
			engine.install

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine buildpacker install"
			ssh.run "smartmachine prereceiver install"

			elasticsearch = SmartMachine::Grids::Elasticsearch.new
			elasticsearch.install
		end

		def stop
			elasticsearch = SmartMachine::Grids::Elasticsearch.new
			elasticsearch.uninstall

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine prereceiver uninstall"
			ssh.run "smartmachine buildpacker uninstall"

			engine = SmartMachine::Engine.new
			engine.uninstall

			SmartMachine::Docker.uninstall
		end

		def grid(*args)
			args.flatten!

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine run grid #{args.join(" ")}"
		end

		def app(*args)
			args.flatten!

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine run app #{args.join(" ")}"
		end

		def ssh
			ssh = SmartMachine::SSH.new
			ssh.login
		end

		# Works only for class methods of the class as no instance of the class is created
		def run(*args)
			args.flatten!

			controller_type = args.shift.pluralize

			if controller_type == "grids"
				controller_name = args.shift
			elsif  controller_type == "apps"
				controller_name = "app"
			else
				raise "Invalid run command. Please try again."
			end

			controller = "SmartMachine::#{controller_type.capitalize}::#{controller_name.capitalize}"
			action = args.shift.to_sym

			args.empty? ? Object.const_get(controller).public_send(action) : Object.const_get(controller).public_send(action, args)
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

		def self.local?
			File.file?("./config/master.key")
		end

		def self.server?
			File.directory?("#{SmartMachine.config.user_home_path}/.smartmachine")
		end

		def sync(first_sync = false)
			puts "-----> Syncing smartmachine ... "
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
			system("rsync -azumv --delete --include={#{sync_pull_files_list}} --exclude=* -e ssh #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:host]}:~/.smartmachine/ .")
		end

		def sync_push
			puts "-----> Sync pushing ... "
			system("rsync -azumv --delete --include={#{sync_push_files_list}} --exclude=* -e ssh ./ #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:host]}:~/.smartmachine")
		end

		def sync_pull_files_list
			files = [
				'apps/***',

				'grids',

				'grids/grid-elasticsearch',
				'grids/grid-elasticsearch/data/***',
				'grids/grid-elasticsearch/logs/***',

				'grids/grid-minio',
				'grids/grid-minio/data/***',

				'grids/grid-mysql',
				'grids/grid-mysql/data/***',

				'grids/grid-nextcloud',
				'grids/grid-nextcloud/html/***',

				'grids/grid-nginx',
				'grids/grid-nginx/certificates/***',

				'grids/grid-redmine',
				'grids/grid-redmine/files/***',

				'grids/grid-solr',
				'grids/grid-solr/solr/***',
			]
			files.join(',')
		end

		def sync_push_files_list
			files = [
				'apps',
				'apps/containers',
				'apps/containers/.keep',
				'apps/repositories',
				'apps/repositories/.keep',

				'bin/***',

				'config',
				'config/credentials.yml.enc',
				'config/environment.rb',

				'grids',

				'grids/grid-elasticsearch',
				'grids/grid-elasticsearch/data',
				'grids/grid-elasticsearch/data/.keep',
				'grids/grid-elasticsearch/logs',
				'grids/grid-elasticsearch/logs/.keep',

				'grids/grid-minio',
				'grids/grid-minio/data',
				'grids/grid-minio/data/.keep',

				'grids/grid-mysql',
				'grids/grid-mysql/data',
				'grids/grid-mysql/data/.keep',

				'grids/grid-nextcloud',
				'grids/grid-nextcloud/html',
				'grids/grid-nextcloud/html/.keep',
				'grids/grid-nextcloud/html/apps',
				'grids/grid-nextcloud/html/apps/.keep',
				'grids/grid-nextcloud/html/config',
				'grids/grid-nextcloud/html/config/.keep',

				'grids/grid-nginx',
				'grids/grid-nginx/certificates',
				'grids/grid-nginx/certificates/.keep',
				'grids/grid-nginx/htpasswd/***',
				'grids/grid-nginx/fastcgi.conf',
				'grids/grid-nginx/nginx.tmpl',

				'grids/grid-prereceiver',
				'grids/grid-prereceiver/pre-receive',

				'grids/grid-redis',
				'grids/grid-redis/data',
				'grids/grid-redis/data/.keep',

				'grids/grid-redmine',
				'grids/grid-redmine/files',
				'grids/grid-redmine/files/.keep',

				'grids/grid-solr',
				'grids/grid-solr/solr',
				'grids/grid-solr/solr/.keep',

				'tmp/***',
			]
			files.join(',')
		end
	end
end