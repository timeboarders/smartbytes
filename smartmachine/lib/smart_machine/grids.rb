# The main SmartMachine Grids
module SmartMachine
	class Grids < SmartMachine::Base
		def run(*args)
			args.flatten!

			grid_name = args.shift
			action = args.shift

			valid_actions = ['up', 'down']
			valid_actions.push(*['backup', 'flushlogs']) if grid_name == 'mysql'
			valid_actions.push(*["start", "stop"]) if grid_name == 'scheduler'
			raise "invalid action on the grid #{grid_name}" unless valid_actions.include? action

			Object.const_get("SmartMachine::Grids::#{grid_name.capitalize}").new.public_send(action, *args)
		end
	end
end
