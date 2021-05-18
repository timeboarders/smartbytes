module SmartWatch
  class Account < Base
    attr_accessor :api_key, :api_secret

    def initialize(api_key:, api_secret:)
      @api_key = api_key
      @api_secret = api_secret
    end

    def login_path
      Login.new(api_key: api_key, api_secret: api_secret).login_redirect_path
    end

    def signed_in?
      false
      # session[:access_token].present?
    end
  end  
end
