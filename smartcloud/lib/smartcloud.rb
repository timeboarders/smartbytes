require "ostruct"
require "yaml"

# The main Smartcloud driver
module Smartcloud
	def self.config
		@@config ||= OpenStruct.new
	end

	def self.credentials
		@@credentials ||= OpenStruct.new(Smartcloud::Credentials.new.config)
	end
end

require 'smartcloud/version'

Smartcloud.config.root_path = File.expand_path('../..', __FILE__)
Smartcloud.config.user_home_path = File.expand_path('~')
if File.exist?("#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb")
	require "#{Smartcloud.config.user_home_path}/.smartcloud/config/environment"
end

require 'smartcloud/base'
require 'smartcloud/boot'
