require 'smart_cloud/logger'
require "active_support/inflector"

module SmartCloud
	class Base
		include SmartCloud::Logger

		def initialize
		end		
	end
end