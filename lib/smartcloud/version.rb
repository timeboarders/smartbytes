# frozen_string_literal: false

module Smartcloud
	VERSION = "0.2.0.beta4".freeze

	def self.version
		@@version ||= VERSION
	end

	def self.smartcloud_major_version
		@smartcloud_major_version ||= VERSION.split(".").first.to_i
	end
end