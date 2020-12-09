require "ostruct"
require "yaml"
require "os"

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

SmartMachine.config.gem_dir = Gem::Specification.find_by_name("smartmachine").gem_dir
SmartMachine.config.cache_dir = Gem::Specification.find_by_name("smartmachine").cache_dir
# SmartMachine.config.user_home_path = File.expand_path('~')
SmartMachine.config.machine_dir = Dir.pwd
if File.exist?("#{SmartMachine.config.machine_dir}/config/environment.rb")
	require "#{SmartMachine.config.machine_dir}/config/environment"
end

require 'smart_machine/base'
require 'smart_machine/boot'
