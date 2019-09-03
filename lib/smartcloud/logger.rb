require "logger"

module Smartcloud
	module Logger
	  def logger
	    @logger ||= Smartcloud::Logger.logger_for(self.class.name)
	  end

	  # Use a hash class-ivar to cache a unique Logger per class:
	  @loggers = {}

	  def self.included(base)
		class << base
			def logger
			  @logger ||= Smartcloud::Logger.logger_for(self.name)
			end
		end
	  end

	  class << self
	    def logger_for(classname)
	      @loggers[classname] ||= configure_logger_for(classname)
	    end

	    def configure_logger_for(classname)
	      logger = ::Logger.new($stdout)
	      logger.progname = classname
	      logger
	    end
	  end
	end
end