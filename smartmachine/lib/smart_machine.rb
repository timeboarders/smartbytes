require 'ostruct'
require 'yaml'

require 'smart_machine/version'
require 'smart_machine/base'

require 'smart_machine/credentials'

require 'smart_machine/ssh'
require 'smart_machine/machine'

require 'smart_machine/docker'
require 'smart_machine/engine'
require 'smart_machine/buildpackers'
require 'smart_machine/syncer'

require 'smart_machine/users'

require 'smart_machine/grids'
require 'smart_machine/grids/elasticsearch'
require 'smart_machine/grids/minio'
require 'smart_machine/grids/mysql'
require 'smart_machine/grids/nginx'
require 'smart_machine/grids/prereceiver'
require 'smart_machine/grids/scheduler'
require 'smart_machine/grids/solr'

require 'smart_machine/apps'
require 'smart_machine/apps/app'
require 'smart_machine/apps/rails'

# The main SmartMachine driver
module SmartMachine
	class Error < StandardError; end

  def self.config
		@@config ||= OpenStruct.new
	end

	def self.credentials
		@@credentials ||= OpenStruct.new(SmartMachine::Credentials.new.config)
	end

  def self.in_machine_dir?
    File.file?("./config/master.key")
  end
end

SmartMachine.config.gem_dir = Gem::Specification.find_by_name("smartmachine").gem_dir
SmartMachine.config.cache_dir = Gem::Specification.find_by_name("smartmachine").cache_dir
# SmartMachine.config.user_home_path = File.expand_path('~')
SmartMachine.config.machine_dir = Dir.pwd
if File.exist?("#{SmartMachine.config.machine_dir}/config/environment.rb")
	require "#{SmartMachine.config.machine_dir}/config/environment"
end
