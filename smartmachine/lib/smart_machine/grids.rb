# The main SmartMachine Grids
module SmartMachine
	class Grids < SmartMachine::Base
		def run(*args)
			args.flatten!

			grid_name = args.shift
			action = args.shift

			raise "invalid action on the grid" unless ['up', 'down'].include? action

			Object.const_get("SmartMachine::Grids::#{grid_name.capitalize}").new.public_send(action, *args)
		end
	end
end
