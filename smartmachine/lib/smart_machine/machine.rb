require "net/ssh"

# The main SmartMachine Machine driver
module SmartMachine
	class Machine < SmartMachine::Base
		def initialize
		end

		def create(*args)
			args.flatten!

			raise "Please specify a machine name" if ARGV.empty?

			name = args.shift
			FileUtils.mkdir name
			FileUtils.cp_r "#{SmartMachine.config.root_path}/lib/smart_machine/templates/dotsmartmachine/.", "#{name}"
			FileUtils.chdir "#{name}" do
				credentials = SmartMachine::Credentials.new
				credentials.create
				system("git init && git add . && git commit -m 'initial commit'")
			end
			puts "New machine #{name} has been created."
		end

		def ssh
			ssh = SmartMachine::SSH.new
			ssh.login
		end

		def install
			SmartMachine::Docker.new.install

			engine = SmartMachine::Engine.new
			engine.install

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine buildpacker install"
			ssh.run "smartmachine prereceiver install"

			elasticsearch = SmartMachine::Grids::Elasticsearch.new
			elasticsearch.install
		end

		def update
		end

		def uninstall
			elasticsearch = SmartMachine::Grids::Elasticsearch.new
			elasticsearch.uninstall

			ssh = SmartMachine::SSH.new
			ssh.run "smartmachine prereceiver uninstall"
			ssh.run "smartmachine buildpacker uninstall"

			engine = SmartMachine::Engine.new
			engine.uninstall

			SmartMachine::Docker.new.uninstall
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

		def self.remote?
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
			system("rsync -azumv --delete --include={#{sync_pull_files_list}} --exclude=* -e ssh #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/.smartmachine/ .")
		end

		def sync_push
			puts "-----> Sync pushing ... "
			system("rsync -azumv --delete --include={#{sync_push_files_list}} --exclude=* -e ssh ./ #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/.smartmachine")
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

				'grids/nginx',
				'grids/nginx/certificates/***',

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

				'grids/solr',
				'grids/solr/solr',
				'grids/solr/solr/.keep',

				'tmp/***',
			]
			files.join(',')
		end
	end
end