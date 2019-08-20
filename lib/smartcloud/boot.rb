require 'securerandom'
require "tempfile"

# The main Smartcloud Boot driver
module Smartcloud
	class Boot
		def initialize
		end

		def self.init
			# Copy Template for dotsmartcloud
			unless self.initialized?
				puts "Initializing Smartcloud ...\n\n"

				begin
					print "Enter top-level apps domain to be used for subdomains of your apps. [Recommended: yourdomain.com]: "
					config_apps_domain = STDIN.gets.chomp
					raise if config_apps_domain.empty?
				rescue
					retry
				end

				begin
					print "Enter sysadmin email id. [Recommended: admin@#{config_apps_domain}]: "
					config_sysadmin_email = STDIN.gets.chomp
					raise if config_sysadmin_email.empty?
				rescue
					retry
				end

				begin
					print "Enter username for your git grid user. [Recommended: git@#{config_apps_domain}]: "
					username = STDIN.gets.chomp
					raise if username.empty?
				rescue
					retry
				end

				print "Enter password for your git grid user. (leave blank to generate automatically) [Recommended: Minimum 8 characters with numbers and symbols]: "
				password = STDIN.gets.chomp
				if password.empty?
					password = SecureRandom.base64(8)
				end

				# Copy dotsmartcloud template to user home directory
				FileUtils.cp_r("#{Smartcloud.config.root_path}/lib/smartcloud/templates/dotsmartcloud", "#{Smartcloud.config.user_home_path}/.smartcloud")

				# modifying environment.rb file
				tempFile = Tempfile.new("#{Smartcloud.config.user_home_path}/.smartcloud/config/environmentTemp.rb")
				File.open("#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb", "r").each_line do |line|
					if line =~ /Smartcloud.config.apps_domain/
						tempFile.puts "Smartcloud.config.apps_domain = \"#{config_apps_domain}\""
					elsif line =~ /Smartcloud.config.git_domain/
						tempFile.puts "Smartcloud.config.git_domain = \"git.#{config_apps_domain}\""
					elsif line =~ /Smartcloud.config.sysadmin_email/
						tempFile.puts "Smartcloud.config.sysadmin_email = \"#{config_sysadmin_email}\""
					else
						tempFile.puts line
					end
				end
				tempFile.close
				FileUtils.mv(tempFile.path, "#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb")			

				# Reload the updated environment.rb file as it is required by methods below
				require "#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb"
				
				# creating user for git grid at config.git_domain
				Smartcloud::User.create(Smartcloud.config.git_domain, username, password)

				puts "\nIMPORTANT NOTE: Please ensure that the required top-level apps domain '#{Smartcloud.config.apps_domain}' and git domain '#{Smartcloud.config.git_domain}' is pointing to this server using DNS Records before proceeding."
				puts "IMPORTANT NOTE: Your git grid password is #{password} for username #{username}"

				puts "\nInitializing Smartcloud ... done"
			else
				puts "Already Initialized. Please go to #{Smartcloud.config.user_home_path}/.smartcloud/config to make configuration changes."
			end
		end

		def self.initialized?
			Dir.exist? "#{Smartcloud.config.user_home_path}/.smartcloud"
		end
	end
end

require 'smartcloud/machine'
require 'smartcloud/docker'

require 'smartcloud/grids/nginx'
require 'smartcloud/grids/runner'
require 'smartcloud/grids/solr'
require 'smartcloud/grids/mysql'

require 'smartcloud/user'
