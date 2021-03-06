require "net/ssh"

# The main SmartCloud Machine driver
module SmartCloud
	class Machine < SmartCloud::Base
		def initialize
		end

		def create(*args)
			args.flatten!

			name = args.shift
			FileUtils.mkdir name
			FileUtils.cp_r "#{SmartCloud.config.root_path}/lib/smartcloud/templates/dotsmartcloud/.", "#{name}"
			FileUtils.chdir "#{name}" do
				credentials = SmartCloud::Credentials.new
				credentials.create
			end
			puts "New machine #{name} has been created."
		end

		def start
			SmartCloud::Docker.new.install

			engine = SmartCloud::Engine.new
			engine.install

			ssh = SmartCloud::SSH.new
			ssh.run "smartcloud buildpacker install"
			ssh.run "smartcloud prereceiver install"

			elasticsearch = SmartCloud::Grids::Elasticsearch.new
			elasticsearch.install
		end

		def stop
			elasticsearch = SmartCloud::Grids::Elasticsearch.new
			elasticsearch.uninstall

			ssh = SmartCloud::SSH.new
			ssh.run "smartcloud prereceiver uninstall"
			ssh.run "smartcloud buildpacker uninstall"

			engine = SmartCloud::Engine.new
			engine.uninstall

			SmartCloud::Docker.new.uninstall
		end

		def grid(*args)
			args.flatten!

			ssh = SmartCloud::SSH.new
			ssh.run "smartcloud run grid #{args.join(" ")}"
		end

		def app(*args)
			args.flatten!

			ssh = SmartCloud::SSH.new
			ssh.run "smartcloud run app #{args.join(" ")}"
		end

		def ssh
			ssh = SmartCloud::SSH.new
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

			controller = "SmartCloud::#{controller_type.capitalize}::#{controller_name.capitalize}"
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

		def self.remote?
			File.directory?("#{SmartCloud.config.user_home_path}/.smartcloud")
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
			system("rsync -azumv --delete --include={#{sync_pull_files_list}} --exclude=* -e ssh #{SmartCloud.credentials.machine[:username]}@#{SmartCloud.credentials.machine[:address]}:~/.smartcloud/ .")
		end

		def sync_push
			puts "-----> Sync pushing ... "
			system("rsync -azumv --delete --include={#{sync_push_files_list}} --exclude=* -e ssh ./ #{SmartCloud.credentials.machine[:username]}@#{SmartCloud.credentials.machine[:address]}:~/.smartcloud")
		end

		def sync_pull_files_list
			files = [
				'apps/***',

				'grids',

				'grids/elasticsearch',
				'grids/elasticsearch/data/***',
				'grids/elasticsearch/logs/***',

				'grids/minio',
				'grids/minio/data/***',

				'grids/mysql',
				'grids/mysql/data/***',

				'grids/nextcloud',
				'grids/nextcloud/html/***',

				'grids/nginx',
				'grids/nginx/certificates/***',

				'grids/redmine',
				'grids/redmine/files/***',

				'grids/solr',
				'grids/solr/solr/***',
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

				'grids/elasticsearch',
				'grids/elasticsearch/data',
				'grids/elasticsearch/data/.keep',
				'grids/elasticsearch/logs',
				'grids/elasticsearch/logs/.keep',

				'grids/minio',
				'grids/minio/data',
				'grids/minio/data/.keep',

				'grids/mysql',
				'grids/mysql/data',
				'grids/mysql/data/.keep',

				'grids/nextcloud',
				'grids/nextcloud/html',
				'grids/nextcloud/html/.keep',
				'grids/nextcloud/html/apps',
				'grids/nextcloud/html/apps/.keep',
				'grids/nextcloud/html/config',
				'grids/nextcloud/html/config/.keep',

				'grids/nginx',
				'grids/nginx/certificates',
				'grids/nginx/certificates/.keep',
				'grids/nginx/htpasswd/***',
				'grids/nginx/fastcgi.conf',
				'grids/nginx/nginx.tmpl',

				'grids/prereceiver',
				'grids/prereceiver/pre-receive',

				'grids/redis',
				'grids/redis/data',
				'grids/redis/data/.keep',

				'grids/redmine',
				'grids/redmine/files',
				'grids/redmine/files/.keep',

				'grids/solr',
				'grids/solr/solr',
				'grids/solr/solr/.keep',

				'tmp/***',
			]
			files.join(',')
		end
	end
end