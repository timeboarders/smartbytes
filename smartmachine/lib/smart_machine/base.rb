require 'smart_machine/logger'
require "active_support/inflector"

module SmartMachine
	class Base
		include SmartMachine::Logger

		def initialize
		end

		def machine_has_linuxos?
			run_commands_by_machine_mode(commands: ["uname | grep -q 'Linux'"])
		end

		def machine_has_macos?
			run_commands_by_machine_mode(commands: ["uname | grep -q 'Darwin'"])
		end

    def machine_has_engine_installed?
      run_commands_by_machine_mode(commands: ["which smartengine | grep -q '/smartengine'"])
    end

		def run_commands_by_machine_mode(commands:)
			commands = Array(commands).flatten

			if SmartMachine.config.machine_mode == :server
				ssh = SmartMachine::SSH.new
				ssh.run commands
			else
				system(commands.join(";"))
			end
		end
	end
end