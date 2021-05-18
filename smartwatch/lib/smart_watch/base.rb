require 'smart_watch/logger'
require "active_support/inflector"

module SmartWatch
  class Base
    include SmartWatch::Logger

    def initialize
    end
  end
end
