require 'smart_machine/logger'
require "active_support/inflector"

module SmartMachine
	class Base
		include SmartMachine::Logger

		def initialize
		end		
	end
end