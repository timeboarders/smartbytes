# The main SmartMachine Boot driver
module SmartMachine
	class Boot < SmartMachine::Base
		def initialize
		end
	end
end

require 'smart_machine/credentials'

require 'smart_machine/ssh'
require 'smart_machine/machine'

require 'smart_machine/docker'
require 'smart_machine/engine'
require 'smart_machine/buildpacker'
require 'smart_machine/sync'

require 'smart_machine/user'

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
