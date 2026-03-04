module AuthHelpers
  def sign_in(user)
    # For controller specs with Devise
    if defined?(@controller)
      # Use Devise's built-in sign_in helper
      super(user)
    end
  end

  def auth_headers(user)
    token = JWT.encode(
      {
        sub: user.id,
        scp: "user",
        aud: nil,
        iat: Time.now.to_i,
        exp: 24.hours.from_now.to_i,
        jti: SecureRandom.uuid
      },
      Rails.application.secret_key_base,
      "HS256"
    )
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :request
end
