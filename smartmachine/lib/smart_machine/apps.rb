# The main SmartMachine Apps
module SmartMachine
	class Apps < SmartMachine::Base
		def run(*args)
			args.flatten!

			action = args.shift

			raise "invalid action on the app" unless ['create', 'destroy', 'start', 'stop'].include? action

			Object.const_get("SmartMachine::Apps::App").public_send(action, *args)
		end
	end
end
