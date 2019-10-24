# The main Smartcloud Boot driver
module Smartcloud
	class Boot < Smartcloud::Base
		def initialize
		end
	end
end

require 'smartcloud/ssh'
require 'smartcloud/machine'

require 'smartcloud/engine'
require 'smartcloud/docker'

require 'smartcloud/user'

require 'smartcloud/grids/mysql'
require 'smartcloud/grids/solr'
require 'smartcloud/grids/buildpacker'
require 'smartcloud/grids/prereceiver'
require 'smartcloud/grids/nginx'

require 'smartcloud/apps/app'
require 'smartcloud/apps/rails'
