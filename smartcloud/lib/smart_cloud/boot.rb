# The main SmartCloud Boot driver
module SmartCloud
	class Boot < SmartCloud::Base
		def initialize
		end
	end
end

require 'smart_cloud/credentials'

require 'smart_cloud/ssh'
require 'smart_cloud/machine'

require 'smart_cloud/docker'
require 'smart_cloud/engine'
require 'smart_cloud/buildpacker'

require 'smart_cloud/user'

require 'smart_cloud/grids/elasticsearch'
require 'smart_cloud/grids/minio'
require 'smart_cloud/grids/mysql'
require 'smart_cloud/grids/nextcloud'
require 'smart_cloud/grids/nginx'
require 'smart_cloud/grids/prereceiver'
require 'smart_cloud/grids/redmine'
require 'smart_cloud/grids/solr'

require 'smart_cloud/apps/app'
require 'smart_cloud/apps/rails'
