require 'yaml'
require "base64"

# The main Smartcloud User driver
module Smartcloud
	class User < Smartcloud::Base
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
					salt = Base64.encode64((("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join)
					file_data += "#{user}:#{password.crypt(salt)}\n"
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