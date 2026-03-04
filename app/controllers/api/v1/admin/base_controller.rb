module Api
  module V1
    module Admin
      class BaseController < Api::V1::BaseController
        before_action :ensure_admin!

        private

        def ensure_admin!
          unless current_user&.admin?
            render json: {
              error: "Access denied. Admin privileges required."
            }, status: :forbidden
          end
        end
      end
    end
  end
end
