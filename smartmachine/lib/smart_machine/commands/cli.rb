module SmartMachine
  module Commands
    class CLI < Thor
      desc "--version", "Shows the current SmartMachine version"
      map ["--version", "-v"] => :version
      def version
        puts "SmartMachine #{SmartMachine.version}"
      end      

      private

      def inside_machine_dir
        if SmartMachine.in_machine_dir?
          yield
        else
          puts "Are you in the correct directory to run this command?"
        end
      end

      def inside_engine_machine_dir
        if ENV["INSIDE_ENGINE"] == "yes"
            inside_machine_dir do
              yield
            end
        else
          raise "Not inside the engine to run this command"
        end
      end
    end
  end
end
