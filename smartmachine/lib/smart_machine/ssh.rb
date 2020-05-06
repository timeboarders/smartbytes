require "net/ssh"

# The main SmartMachine SSH driver
module SmartMachine
	class SSH < SmartMachine::Base
		def initialize
		end

		def run(*commands)
			commands.flatten!
			Net::SSH.start(SmartMachine.credentials.machine[:host], SmartMachine.credentials.machine[:username], { port: SmartMachine.credentials.machine[:port], password: SmartMachine.credentials.machine[:password] }) do |ssh|
				channel = ssh.open_channel do |channel, success|
					channel.request_pty do |channel, success|
						channel.exec commands.join(';') do |channel, success|
							raise "Could not execute command" unless success

							channel.on_data do |channel, data|
								$stdout.print data

								if data =~ /^\[sudo\] password for /
									channel.send_data "#{SmartMachine.credentials.machine[:password]}\n"
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
			exec "ssh #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:host]}"
		end
	end
end