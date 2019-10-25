# The main Smartcloud Boot driver
module Smartcloud
	class Boot < Smartcloud::Base
		def initialize
		end
	end
end

require 'smartcloud/credentials'

require 'smartcloud/ssh'
require 'smartcloud/machine'

require 'smartcloud/docker'
require 'smartcloud/engine'
require 'smartcloud/buildpacker'

require 'smartcloud/user'

require 'smartcloud/grids/mysql'
require 'smartcloud/grids/nginx'
require 'smartcloud/grids/prereceiver'
require 'smartcloud/grids/solr'

require 'smartcloud/apps/app'
require 'smartcloud/apps/rails'
