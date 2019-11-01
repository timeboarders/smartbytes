# frozen_string_literal: false

module Smartcloud
	VERSION = "0.3.1".freeze

	def self.version
		@@version ||= VERSION
	end

	def self.smartcloud_major_version
		@smartcloud_major_version ||= VERSION.split(".").first.to_i
	end
end