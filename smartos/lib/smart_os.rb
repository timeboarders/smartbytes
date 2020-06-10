require "ostruct"
require "yaml"

# The main SmartOS driver
module SmartOS
	def self.config
		@@config ||= OpenStruct.new
	end

	def self.credentials
		@@credentials ||= OpenStruct.new(SmartOS::Credentials.new.config)
	end
end

require 'smart_os/version'
