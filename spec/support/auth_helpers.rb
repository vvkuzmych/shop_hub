module AuthHelpers
  def sign_in(user)
    # For controller specs with Devise
    if defined?(@controller)
      # Use Devise's built-in sign_in helper
      super(user)
    end
  end

  def auth_headers(user)
    headers = { "Accept" => "application/json", "Content-Type" => "application/json" }
    Devise::JWT::TestHelpers.auth_headers(headers, user)
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :request
end
