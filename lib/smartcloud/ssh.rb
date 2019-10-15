require "net/ssh"

# The main Smartcloud SSH driver
module Smartcloud
	class SSH < Smartcloud::Base
		def initialize
		end

		def run(*commands)
			commands.flatten!
			Net::SSH.start(Smartcloud.credentials.machine[:hostname], Smartcloud.credentials.machine[:username], { port: Smartcloud.credentials.machine[:port], password: Smartcloud.credentials.machine[:password] }) do |ssh|
				channel = ssh.open_channel do |channel, success|
					channel.request_pty do |channel, success|
						channel.exec commands.join(';') do |channel, success|
							raise "Could not execute command" unless success

							channel.on_data do |channel, data|
								if data =~ /^\[sudo\] password for /
									$stdout.print data
									channel.send_data "#{Smartcloud.credentials.machine[:password]}\n"
								else
									$stdout.print data
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
			exec "ssh #{Smartcloud.credentials.machine[:username]}@#{Smartcloud.credentials.machine[:hostname]}"
		end
	end
end