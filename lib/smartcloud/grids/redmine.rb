# The main Smartcloud Grids Redmine driver
module Smartcloud
	module Grids
		class Redmine < Smartcloud::Base
			def initialize
			end

			def self.up(*args)
				args.flatten!
				exposed = args.empty? ? '' : args.shift

				if Smartcloud::Docker.running?
				end
			end
	
			def self.down
				if Smartcloud::Docker.running?
				end
			end			
		end
	end
end