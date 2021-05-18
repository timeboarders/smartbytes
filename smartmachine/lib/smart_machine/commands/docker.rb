module SmartMachine
  module Commands
    class CLI < Thor
      desc "docker:install", "Install docker"
      map ["docker:install"] => :docker_install
      def docker_install
        inside_machine_dir do
          docker = SmartMachine::Docker.new
          docker.install
        end
      end

      desc "docker:uninstall", "Uninstall docker"
      map ["docker:uninstall"] => :docker_uninstall
      def docker_uninstall
        inside_machine_dir do
          docker = SmartMachine::Docker.new
          docker.uninstall
        end
      end
      
      desc "docker [COMMAND]", "Run docker commands on the machine"
      def docker(*commands)
          inside_machine_dir do
            docker = SmartMachine::Docker.new
            docker.run_commands_by_machine_mode(commands: "docker #{commands.join(' ')}")
          end
      end
    end
  end
end
