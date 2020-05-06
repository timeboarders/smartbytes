require "ostruct"
require "yaml"

# The main SmartMachine driver
module SmartMachine
	def self.config
		@@config ||= OpenStruct.new
	end

	def self.credentials
		@@credentials ||= OpenStruct.new(SmartMachine::Credentials.new.config)
	end
end

require 'smart_machine/version'

SmartMachine.config.root_path = File.expand_path('../..', __FILE__)
SmartMachine.config.user_home_path = File.expand_path('~')
if File.exist?("#{SmartMachine.config.user_home_path}/.smartmachine/config/environment.rb")
	require "#{SmartMachine.config.user_home_path}/.smartmachine/config/environment"
end

require 'smart_machine/base'
require 'smart_machine/boot'
