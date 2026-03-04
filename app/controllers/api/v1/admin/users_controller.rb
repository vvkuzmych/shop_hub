module Api
  module V1
    module Admin
      class UsersController < BaseController
        before_action :set_user, only: [ :show ]

        def index
          users = User.page(params[:page] || 1).per(params[:per_page] || 20)
          render json: users.map { |user|
            {
              id: user.id,
              email: user.email,
              full_name: user.full_name,
              role: user.role,
              orders_count: user.orders.count,
              created_at: user.created_at
            }
          }, status: :ok
        end

        def show
          render json: {
            id: @user.id,
            email: @user.email,
            first_name: @user.first_name,
            last_name: @user.last_name,
            full_name: @user.full_name,
            role: @user.role,
            orders_count: @user.orders.count,
            reviews_count: @user.reviews.count,
            created_at: @user.created_at
          }, status: :ok
        end

        private

        def set_user
          @user = User.find(params[:id])
        end
      end
    end
  end
end
