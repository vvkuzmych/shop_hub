module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      respond_to :json

      # Override Devise's sign_up
      def create
        build_resource(sign_up_params)

        if resource.save
          sign_in(resource_name, resource)
          render json: {
            message: "Signed up successfully",
            user: user_response(resource)
          }, status: :created
        else
          render json: {
            message: "User couldn't be created successfully",
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            message: "Signed up successfully",
            user: user_response(resource)
          }, status: :created
        else
          render json: {
            message: "User couldn't be created successfully",
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
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
