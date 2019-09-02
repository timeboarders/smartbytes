require "ostruct"
require "logger"

# The main Smartcloud driver
module Smartcloud
	def self.config
		@@config ||= OpenStruct.new
	end
end

Smartcloud.config.root_path = File.expand_path('../..', __FILE__)
Smartcloud.config.user_home_path = File.expand_path('~')
if File.exist?("#{Smartcloud.config.user_home_path}/.smartcloud/config/environment.rb")
	require "#{Smartcloud.config.user_home_path}/.smartcloud/config/environment"
end

require 'smartcloud/boot'
