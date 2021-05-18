module SmartMachine
  module Commands
    class CLI < Thor
      desc "ssh", "SSH into the machine"
      def ssh
        inside_machine_dir do
          ssh = SmartMachine::SSH.new
          ssh.login
        end
      end
    end
  end
end
