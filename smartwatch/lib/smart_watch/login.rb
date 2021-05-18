module SmartWatch
  class Login < Base
    attr_accessor :login_redirect_path, :request_token, :access_token

    def initialize(api_key:, api_secret:)
      @login_redirect_path = "https://www.abc.com/connect/login?v=3&api_key=#{api_key}"
    end

    def redirect
      puts Faraday.get(login_redirect_path).inspect
    end

    def destroy
      "https://www.abc.com/session/token?api_key=xxx&access_token=yyy"
      "https://www.abc.com/session/token"
    end
  end  
end
