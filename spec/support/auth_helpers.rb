module AuthHelpers
  def sign_in(user)
    token = generate_token(user)
    request.headers["Authorization"] = "Bearer #{token}"
  end

  def generate_token(user)
    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    JWT.encode(payload, Rails.application.secret_key_base, "HS256")
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :controller
  config.include AuthHelpers, type: :request
end
