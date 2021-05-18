module SmartWatch
  class User < Base
    def initialize
      API.new(endpoint: "https://api.abc.com", version: 3)
      response = Faraday.get SmartWatch.config.api_endpoint
    end
  end  
end
