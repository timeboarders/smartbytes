module SmartWatch
  module Commands
    class CLI < Thor
      desc "--version", "Shows the current SmartWatch version"
      map ["--version", "-v"] => :version
      def version
        puts "SmartWatch #{SmartWatch.version}"
      end
    end
  end
end
