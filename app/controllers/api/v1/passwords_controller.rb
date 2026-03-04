module Api
  module V1
    class PasswordsController < Devise::PasswordsController
      respond_to :json

      # POST /api/v1/password
      def create
        self.resource = resource_class.send_reset_password_instructions(resource_params)

        if successfully_sent?(resource)
          render json: {
            message: "Password reset instructions have been sent to your email"
          }, status: :ok
        else
          render json: {
            message: "Email not found",
            errors: resource.errors.full_messages
          }, status: :not_found
        end
      end

      # PUT /api/v1/password
      def update
        self.resource = resource_class.reset_password_by_token(resource_params)

        if resource.errors.empty?
          resource.unlock_access! if unlockable?(resource)
          render json: {
            message: "Password has been reset successfully"
          }, status: :ok
        else
          render json: {
            message: "Password could not be reset",
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def resource_params
        params.require(:user).permit(:email, :reset_password_token, :password, :password_confirmation)
      end
    end
  end
end
