# The main Smartcloud driver
module Smartcloud
	def self.root
		@@root ||= File.expand_path('../..', __FILE__)
	end

	def self.user_home
		@@user_home ||= File.expand_path('~')
	end

	def self.domain
		"yourdomain.com"
	end

	def self.admin_email
		"admin@yourdomain.com"
	end

	def self.letsencrypt_test
		false
	end
end

require 'smartcloud/docker'
require 'smartcloud/grids/git'
require 'smartcloud/grids/nginx'
require 'smartcloud/grids/solr'