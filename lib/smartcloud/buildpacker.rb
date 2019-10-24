require 'open3'

module Smartcloud
	class Buildpacker < Smartcloud::Base
		def initialize
		end

		def pack
			if File.exist? "bin/rails"
				rails = Smartcloud::Apps::Rails.new
				rails.pack
			end
		end
	end
end
