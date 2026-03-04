module Api
  module V1
    class SessionsController < Devise::SessionsController
      respond_to :json
      skip_before_action :verify_signed_out_user, only: :destroy

      def destroy
        if request.headers["Authorization"].present?
          jwt_payload = JWT.decode(request.headers["Authorization"].split(" ").last, Rails.application.secret_key_base, true, algorithm: "HS256").first
          current_user = User.find(jwt_payload["sub"])
        end

        signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
        render json: {
          message: "Logged out successfully"
        }, status: :ok
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        render json: {
          message: "Couldn't find an active session"
        }, status: :unauthorized
      end

      private

      def respond_with(resource, _opts = {})
        render json: {
          message: "Logged in successfully",
          user: user_response(resource)
        }, status: :ok
      end

      def respond_to_on_destroy
        head :no_content
      end

      def user_response(user)
        {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          full_name: user.full_name,
          role: user.role
        }
      end
    end
  end
end
