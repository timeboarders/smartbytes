# frozen_string_literal: true

module SmartMachine
  # Returns the version of the currently loaded SmartMachine as a <tt>Gem::Version</tt>.
  def self.gem_version
    Gem::Version.new VERSION::STRING
  end

  def self.ruby_version
    "2.7.0"
  end

  module VERSION
    MAJOR = 0
    MINOR = 9
    TINY  = 0
    PRE   = nil

    STRING = [MAJOR, MINOR, TINY, PRE].compact.join(".")
  end
end
