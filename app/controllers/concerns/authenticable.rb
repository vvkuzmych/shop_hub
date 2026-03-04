module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    token = extract_token_from_header
    @current_user = decode_token(token) if token
  end

  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end

  def extract_token_from_header
    request.headers["Authorization"]&.split(" ")&.last
  end

  def decode_token(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: "HS256")
    User.find_by(id: decoded.first["user_id"])
  rescue JWT::DecodeError, JWT::VerificationError
    nil
  end
end
