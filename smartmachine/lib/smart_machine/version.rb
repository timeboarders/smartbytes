# frozen_string_literal: false

version = File.read(File.expand_path("SMARTBYTES_VERSION", __dir__)).strip

module SmartMachine
	VERSION = version.freeze

	def self.version
		@@version ||= VERSION
	end

	def self.smart_machine_major_version
		@smart_machine_major_version ||= VERSION.split(".").first.to_i
	end
end