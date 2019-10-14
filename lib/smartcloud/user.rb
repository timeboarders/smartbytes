require 'yaml'
require "base64"

# The main Smartcloud User driver
module Smartcloud
	class User < Smartcloud::Base
		def initialize
		end

		def self.create(hostname, username, password)
			if hostname.nil? || hostname.empty? || username.nil? || username.empty? || password.nil? || password.empty?
				puts "One of hostname, username, password missing."
			else
				puts "-----> Creating User ... "

				salt = Base64.encode64((("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join)
				new_user = { "#{hostname}" => { "#{username}" => "#{password.crypt(salt)}" } }
				users = self.get_users_from_file
				users.merge!(new_user) { |hostname, curr_user_vals, new_user_val| (curr_user_vals && new_user_val) ? curr_user_vals.merge(new_user_val) : new_user_val }
				self.set_users_to_file(users)

				puts "-----> Creating User ... done"
			end
		end

		# def self.destroy(hostname, username)
		# 	if hostname.nil? || hostname.empty? || username.nil? || username.empty?
		# 		puts "One of hostname, username missing."
		# 	else
		# 		puts "-----> Removing User ... "
		#
		# 		users = self.get_users_from_file
		# 		# users.merge!(new_user)
		# 		self.set_users_to_file(users)
		#
		# 		puts "-----> Removing User ... done"
		# 	end
		# end
		
		private

		def self.get_users_from_file
			YAML.load_file("#{Smartcloud.config.user_home_path}/.smartcloud/config/users.yml") || Hash.new
		end
		
		def self.set_users_to_file(users)
			File.open("#{Smartcloud.config.user_home_path}/.smartcloud/config/users.yml", "w") { |file| file.write(users.to_yaml) }
			self.create_htpasswd_files
		end

		def self.create_htpasswd_files
			htpasswd_dirpath = "#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-nginx/htpasswd"
			
			# Remove existing htpasswd_dirpath
			FileUtils.rm_r htpasswd_dirpath if Dir.exist?(htpasswd_dirpath)
			
			# Create new htpasswd_dirpath
			FileUtils.mkdir htpasswd_dirpath

			# Add hostfiles to htpasswd_dirpath
			self.get_users_from_file.each do |hostname, users|
				next unless users

				file_data = ""
				users.each do |user, password|
					file_data += "#{user}:#{password}\n"
				end
				File.open("#{Smartcloud.config.user_home_path}/.smartcloud/grids/grid-nginx/htpasswd/#{hostname}", "w") { |file| file.write(file_data) }
			end
		end
	end
end