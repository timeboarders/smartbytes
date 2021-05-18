module SmartMachine
  module Commands
    class CLI < Thor
      desc "credentials:edit", "Allows editing the credentials"
      map ["credentials:edit"] => :credentials_edit
      def credentials_edit
        inside_machine_dir do
          credentials = SmartMachine::Credentials.new
          credentials.edit
        end
      end
    end
  end
end
