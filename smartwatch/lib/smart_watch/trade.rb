module SmartWatch
  class Trade < Base
    def initialize
      response = Faraday.get SmartWatch.config.api_endpoint
      puts response.status
      puts response.headers
      puts response.body
    end
  end  
end
