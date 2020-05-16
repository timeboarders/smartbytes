# The main SmartMachine Grids Mysql driver
module SmartMachine
	class Grids
		class Mysql < SmartMachine::Base
			def initialize
			end

			def up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if SmartMachine::Docker.running?
					# Creating networks
					unless system("docker network inspect mysql-network", [:out, :err] => File::NULL)
						print "-----> Creating network mysql-network ... "
						if system("docker network create mysql-network", out: File::NULL)
							puts "done"
						end
					end

					# Creating & Starting containers
					print "-----> Creating container mysql ... "
					if system("docker create \
						--name='#{container_name}' \
						--env MYSQL_ROOT_PASSWORD=#{SmartMachine.credentials.mysql[:root_password]} \
						--env MYSQL_USER=#{SmartMachine.credentials.mysql[:username]} \
						--env MYSQL_PASSWORD=#{SmartMachine.credentials.mysql[:password]} \
						--env MYSQL_DATABASE=#{SmartMachine.credentials.mysql[:database_name]} \
						--user `id -u`:`id -g` \
						#{"--publish='#{SmartMachine.credentials.mysql[:port]}:#{SmartMachine.credentials.mysql[:port]}'" if exposed == '--exposed'} \
						--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/mysql/data:/var/lib/mysql' \
						--restart='always' \
						--network='mysql-network' \
						mysql:8.0.18", out: File::NULL)

						puts "done"
						print "-----> Starting container mysql ... "
						if system("docker start mysql", out: File::NULL)
							puts "done"
						end
					end
				end
			end
	
			def down
				if SmartMachine::Docker.running?
					# Stopping & Removing containers - in reverse order
					print "-----> Stopping container mysql ... "
					if system("docker stop 'mysql'", out: File::NULL)
						puts "done"
						print "-----> Removing container mysql ... "
						if system("docker rm 'mysql'", out: File::NULL)
							puts "done"
						end
					end

					# Removing networks
					print "-----> Removing network mysql-network ... "
					if system("docker network rm mysql-network", out: File::NULL)
						puts "done"
					end
				end
			end

			# TODO: Setup automatic actions for
			# flushlogs at 12am and 12 pm every day
			# daily backup at 2 am
			# weekly backup at 2 am after daily backup is completed
			# Check flush logs working
			# Check if weekly is showing error when daily is not present

			# Flushing logs
			def flushlogs(*args)
				system("docker exec #{container_name} sh -c 'exec mysqladmin flush-logs'")
			end

			# Create backup using the grids backup command
			def backup(*args)
				args.flatten!
				type = args.empty? ? '--snapshot' : args.shift

				if type == "--daily"
					run_backup(type: "daily")
				elsif type == "--weekly"
					run_backup(type: "weekly")
				elsif type == "--snapshot"
					run_backup(type: "snapshot")
				elsif type == "--transfer"
					transfer_backups_to_external_storage
				end
			end

			private

			# Transfer all current backups to external storage
			def transfer_backups_to_external_storage
			end

			def run_backup(type:)
				FileUtils.mkdir_p("#{backups_path}/#{type}")

				unless type == "weekly"
					standard_backup(type: type)
				else
					weekly_backup_from_latest_daily
				end
			end

			def restore(type:, version:)
				printf "Are you sure you want to do this? It will destroy all the old databases? Type 'YES' and press enter to continue: ".red
				prompt = STDIN.gets.chomp
				return unless prompt == 'YES'

				print "-----> Restoring the backup of all databases with version #{version} (without binlogs) in #{container_name} ... "
				if system("docker exec -i #{container_name} sh -c \
					'exec mysql \
					--user=root \
					--password=#{SmartMachine.credentials.mysql[:root_password]} \
					< #{backups_path}/#{type}/#{version}.sql")

					puts "done"
				else
					puts "error... check data & try again"
				end
			end

			# Create a standard backup
			def standard_backup(type:)
				# Note: There should be no space between + and " in version.
				# Note: date will be UTC date until timezone has been changed.
				version = `date +"%Y%m%d%H%M%S"`.chomp!

				print "-----> Creating #{type} backup of all databases with version #{version} in #{container_name} ... "
				if system("docker exec #{container_name} sh -c \
					'exec mysqldump \
					--user=root \
					--password=#{SmartMachine.credentials.mysql[:root_password]} \
					--all-databases \
					--single-transaction \
					--flush-logs \
					--master-data=2 \
					--events \
					--routines \
					--triggers \
					2>/dev/null | grep -v \'mysqldump: [Warning] Using a password\'' \
					> #{backups_path}/#{type}/#{version}.sql")

					puts "done"

					clean_up(type: type)
				else
					puts "error... check data & try again"
				end
			end

			# Copy weekly backup from the daily backup
			def weekly_backup_from_latest_daily
				Dir.chdir("#{backups_path}/daily") do
					backup_versions = Dir.glob('*').sort
					backup_version = backup_versions.last

					if backup_version
						print "-----> Creating weekly backup from daily backup with version #{backup_version} ... "
						system("cp ./#{backup_version} ../weekly/#{backup_version}")
						puts "done"

						clean_up(type: "weekly")
					else
						puts "-----> Could not find daily backup to copy to weekly ... error"
					end
				end
			end

			# Clean up very old versions
			def clean_up(type:)
				keep_releases = { snapshot: 2, daily: 7, weekly: 3 }

				Dir.chdir("#{backups_path}/#{type}") do
					backup_versions = Dir.glob('*').sort
					destroy_count = backup_versions.count - keep_releases[type.to_sym]
					if destroy_count > 0
						print "Deleting older #{type} backups ... "
						destroy_count.times do
							FileUtils.rm_r(File.join(Dir.pwd, backup_versions.shift))
						end
						puts "done"
					end
				end
			end

			def backups_path
				"#{SmartMachine.config.user_home_path}/.smartmachine/grids/mysql/backups"
			end

			def container_name
				"mysql"
			end
		end
	end
end