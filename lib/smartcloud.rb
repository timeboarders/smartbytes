require 'smartcloud/config/environment'

# The main Smartcloud driver
module Smartcloud
	def self.root
		@@root ||= File.expand_path('../..', __FILE__)
	end
end

require 'smartcloud/docker'
require 'smartcloud/grids/git'
require 'smartcloud/grids/nginx'
require 'smartcloud/grids/solr'