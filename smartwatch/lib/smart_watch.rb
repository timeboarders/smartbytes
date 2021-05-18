require 'ostruct'
require 'yaml'

require 'smart_watch/version'
require 'smart_watch/base'

require 'smart_watch/connection'

require 'smart_watch/login'
require 'smart_watch/account'
require 'smart_watch/user'
require 'smart_watch/trade'

# The main SmartWatch driver
module SmartWatch
	class Error < StandardError; end

  def self.config
		@@config ||= OpenStruct.new
	end
end
