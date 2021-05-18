module SmartWatch
  class Connection < Base
    attr_accessor :endpoint, :version

    def initialize(endpoint: "https://abc.com", version: 3)
      @endpoint = endpoint
      @version = version
    end

    def get(url:)
      request(url: url, method: :get)
    end

    def post(url:, body:)
      request(url: url, method: :post, body: body)
    end

    def put(url:, body:)
      request(url: url, method: :put, body: body)
    end

    def patch(url:, body:)
      request(url: url, method: :patch, body: body)
    end

    def delete(url:)
      request(url: url, method: :delete)
    end

    def request(url: , method: , body: nil)
      connection = Faraday.new(
        url: endpoint,
        headers: {
          'X-Abc-version' => version
        }
      )

      response = connection.public_send(method)
    end
  end  
end
