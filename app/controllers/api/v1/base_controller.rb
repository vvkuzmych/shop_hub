module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable      # Custom module для auth
      include ExceptionHandler   # Custom module для errors
      include Paginable          # Custom module для pagination

      before_action :authenticate_user!

      private

      def current_user
        @current_user ||= User.find_by(id: decoded_token["user_id"])
      end
    end
  end
end
