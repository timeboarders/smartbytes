# The main SmartMachine Grids Scheduler driver
module SmartMachine
	class Grids
		class Scheduler < SmartMachine::Base

			def initialize
			end

			def install
				puts "-----> Installing Scheduler"

				ssh = SmartMachine::SSH.new
				commands = ["smartmachine runner scheduler create"]
				ssh.run commands

				puts "-----> Scheduler Installation Complete"
			end

			def uninstall
				puts "-----> Uninstalling Scheduler"

				ssh = SmartMachine::SSH.new
				commands = ["smartmachine runner scheduler destroy"]
				ssh.run commands

				puts "-----> Scheduler Uninstallation Complete"
			end

			def update
				uninstall
				install
			end

			def create
				unless system("docker image inspect #{scheduler_image_name}", [:out, :err] => File::NULL)
					print "-----> Creating image #{scheduler_image_name} ... "
					if system("docker image build -t #{scheduler_image_name} \
									--build-arg SMARTMACHINE_VERSION=#{SmartMachine.version} \
									#{SmartMachine.config.root_path}/lib/smart_machine/grids/scheduler", out: File::NULL)
						puts "done"

						up
					end
				end
			end

			def destroy
				down

				if system("docker image inspect #{scheduler_image_name}", [:out, :err] => File::NULL)
					print "-----> Removing image #{scheduler_image_name} ... "
					if system("docker image rm #{scheduler_image_name}", out: File::NULL)
						puts "done"
					end
				end
			end

			def up
				if SmartMachine::Docker.running?
					if system("docker image inspect #{scheduler_image_name}", [:out, :err] => File::NULL)
						print "-----> Creating container scheduler with image #{scheduler_image_name} ... "
						if system("docker create \
							--name='scheduler' \
							--env MAILTO=#{SmartMachine.config.sysadmin_email} \
							--user `id -u`:`id -g` \
							--workdir /home/`id -un`/.smartmachine \
							--volume='#{SmartMachine.config.user_home_path}/.smartmachine/config:#{SmartMachine.config.user_home_path}/.smartmachine/config' \
							--volume='#{SmartMachine.config.user_home_path}/.smartmachine/grids/scheduler/crontabs:/crontabs' \
							--volume='/var/run/docker.sock:/var/run/docker.sock:ro' \
							--restart='always' \
							#{scheduler_image_name}", out: File::NULL)
							puts "done"

							print "-----> Starting container scheduler with image #{scheduler_image_name} ... "
							if system("docker start scheduler", out: File::NULL)
								puts "done"

								restore_crontabs
							else
								puts "error"
							end
						end
					end
				end
			end
	
			def down
				if SmartMachine::Docker.running?
					# Stopping & Removing containers - in reverse order
					if system("docker inspect -f '{{.State.Running}}' 'scheduler'", [:out, :err] => File::NULL)
						print "-----> Stopping container scheduler with image #{scheduler_image_name} ... "
						if system("docker stop 'scheduler'", out: File::NULL)
							puts "done"

							print "-----> Removing container scheduler with image #{scheduler_image_name} ... "
							if system("docker rm 'scheduler'", out: File::NULL)
								puts "done"
							end
						end
					else
						puts "-----> Container 'scheduler' is currently not running."
					end
				end
			end


			def start(*args)
				args.flatten!
				type = args.empty? ? '--all' : args.shift

				self.class.running!

				if type == '--mysql'
					system("docker exec -i scheduler sh -c 'exec scheduler start --mysql'")
				end
			end

			def stop(*args)
				args.flatten!
				type = args.empty? ? '--all' : args.shift

				self.class.running!

				if type == '--mysql'
					system("docker exec -i scheduler sh -c 'exec scheduler stop --mysql'")
				end
			end

			def mysql(*args)
				args.flatten!
				action = args.empty? ? '' : args.shift

				if action == 'start'
					print "-----> Starting automatic backup schedule for mysql ... "
					if system("whenever --load-file #{SmartMachine.config.user_home_path}/.smartmachine/config/mysql/schedule.rb --update-crontab", out: File::NULL)
						puts "done"
					else
						puts "error"
					end
				elsif action == 'stop'
					print "-----> Stopping automatic backup schedule for mysql ... "
					if system("whenever --load-file #{SmartMachine.config.user_home_path}/.smartmachine/config/mysql/schedule.rb --clear-crontab", out: File::NULL)
						puts "done"
					else
						puts "error"
					end
				end
			ensure
				backup_crontabs
			end

			def scheduler_image_name
				"smartmachine/scheduler:#{SmartMachine.version}"
			end

			def restore_crontabs
				if system("docker exec scheduler sh -c 'exec test -f /crontabs/`id -un`'")
					print "-----> Restoring latest crontabs ... "

					if system("docker exec scheduler sh -c 'exec crontab - < /crontabs/`id -un`'")
						puts "done"
					else
						puts "error"
					end
				end
			end

			def backup_crontabs
				print "-----> Backing up latest crontabs ... "
				if system("crontab -l > /crontabs/`id -un`", out: File::NULL)
					puts "done"
				else
					puts "error"
				end
			end

			def self.running!
				unless system("docker inspect -f '{{.State.Running}}' 'scheduler'", [:out, :err] => File::NULL)
					raise "Scheduler is not running. Please start scheduler before scheduling"
				end
			end
		end
	end
end