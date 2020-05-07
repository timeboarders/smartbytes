require "net/ssh"

# The main SmartCloud SSH driver
module SmartCloud
	class SSH < SmartCloud::Base
		def initialize
		end

		def run(*commands)
			commands.flatten!
			Net::SSH.start(SmartCloud.credentials.machine[:address], SmartCloud.credentials.machine[:username], { port: SmartCloud.credentials.machine[:port], password: SmartCloud.credentials.machine[:password] }) do |ssh|
				channel = ssh.open_channel do |channel, success|
					channel.request_pty do |channel, success|
						channel.exec commands.join(';') do |channel, success|
							raise "Could not execute command" unless success

							channel.on_data do |channel, data|
								$stdout.print data

								if data =~ /^\[sudo\] password for /
									channel.send_data "#{SmartCloud.credentials.machine[:password]}\n"
								end
							end

							channel.on_extended_data do |channel, type, data|
								$stderr.print data
							end

							channel.on_close do |channel|
								# puts "done!"
							end
						end
					end
				end
				channel.wait
			end
		end

		def login
			exec "ssh #{SmartCloud.credentials.machine[:username]}@#{SmartCloud.credentials.machine[:address]}"
		end
	end
end