require "ostruct"
require "tempfile"

# The main Smartcloud driver
module Smartcloud
	def self.config
		@@config ||= OpenStruct.new
	end

	def self.root
		@@root ||= File.expand_path('../..', __FILE__)
	end

	def self.user_home
		@@user_home ||= File.expand_path('~')
	end

	def self.init
		# Copy Template for dotsmartcloud
		unless Dir.exist? "#{Smartcloud.user_home}/.smartcloud"
			FileUtils.cp_r("#{Smartcloud.root}/lib/smartcloud/templates/dotsmartcloud", "#{Smartcloud.user_home}/.smartcloud")

			# Setup environment values
			begin
				print "Enter your domain without any subdomain (Eg: yourdomain.com): "
				config_domain = STDIN.gets.chomp
				raise if config_domain.empty?
			rescue
				retry
			end

			config_git_subdomain = "git"
			print "Enter subdomain for git grid setup. Eg: If you want gitlive.#{config_domain}, then enter gitlive. [Default: #{config_git_subdomain}]: "
			subdomain = STDIN.gets.chomp
			config_git_subdomain = subdomain unless subdomain.empty?

			config_admin_email = "admin@#{config_domain}"
			print "Enter admin email id. [Default: #{config_admin_email}]: "
			admin_email = STDIN.gets.chomp
			config_admin_email = admin_email unless admin_email.empty?

			# modifying environment.rb file
			tempFile = Tempfile.new("#{Smartcloud.user_home}/.smartcloud/config/environmentTemp.rb")
			File.open("#{Smartcloud.user_home}/.smartcloud/config/environment.rb", "r").each_line do |line|
				if line =~ /Smartcloud.config.domain/
					tempFile.puts "Smartcloud.config.domain = \"#{config_domain}\""
				elsif line =~ /Smartcloud.config.admin_email/
					tempFile.puts "Smartcloud.config.admin_email = \"#{config_admin_email}\""
				elsif line =~ /Smartcloud.config.git_subdomain/
					tempFile.puts "Smartcloud.config.git_subdomain = \"#{config_git_subdomain}\""
				else
					tempFile.puts line
				end
			end
			tempFile.close
			FileUtils.mv(tempFile.path, "#{Smartcloud.user_home}/.smartcloud/config/environment.rb")

			puts "\nIMPORTANT NOTE: Please ensure that the required domain '#{config_domain}' and/or its required subdomains are pointing to this server using DNS Records."
			puts "\nInitialising Smartcloud ... done"
		else
			puts "Already Initialized. Please go to #{Smartcloud.user_home}/.smartcloud/config to make configuration changes."
		end
	end

	def self.initialised!
		unless Dir.exist? "#{Smartcloud.user_home}/.smartcloud"
			puts "Smartcloud has not been initialized. Please run command 'smartcloud init'"
			exit
		end
	end
end

if File.exists?("#{Smartcloud.user_home}/.smartcloud/config/environment.rb")
	require "#{Smartcloud.user_home}/.smartcloud/config/environment"
end

require 'smartcloud/docker'
require 'smartcloud/grids/git'
require 'smartcloud/grids/nginx'
require 'smartcloud/grids/solr'
