require 'yaml'
require "base64"
require 'bcrypt'

# The main SmartMachine User driver
module SmartMachine
	class User < SmartMachine::Base
		def initialize
		end

		def self.create_htpasswd_files
			htpasswd_dirpath = "#{Dir.pwd}/grids/grid-nginx/htpasswd"

			# Remove existing htpasswd_dirpath
			FileUtils.rm_r htpasswd_dirpath if Dir.exist?(htpasswd_dirpath)
			
			# Create new htpasswd_dirpath
			FileUtils.mkdir htpasswd_dirpath

			# Add hostfiles to htpasswd_dirpath
			self.get_users_from_file.each do |hostname, users|
				next unless users

				file_data = ""
				users.each do |user, password|
					file_data += "#{user}:#{BCrypt::Password.create(password)}\n"
				end
				File.open("#{Dir.pwd}/grids/grid-nginx/htpasswd/#{hostname}", "w") { |file| file.write(file_data) }
			end
		end

		private

		def self.get_users_from_file
			YAML.load_file("#{Dir.pwd}/config/users.yml") || Hash.new
		end
	end
end