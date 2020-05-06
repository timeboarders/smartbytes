require "ostruct"
require "yaml"

# The main SmartCloud driver
module SmartCloud
	def self.config
		@@config ||= OpenStruct.new
	end

	def self.credentials
		@@credentials ||= OpenStruct.new(SmartCloud::Credentials.new.config)
	end
end

require 'smart_cloud/version'

SmartCloud.config.root_path = File.expand_path('../..', __FILE__)
SmartCloud.config.user_home_path = File.expand_path('~')
if File.exist?("#{SmartCloud.config.user_home_path}/.smartcloud/config/environment.rb")
	require "#{SmartCloud.config.user_home_path}/.smartcloud/config/environment"
end

require 'smart_cloud/base'
require 'smart_cloud/boot'
