module Api
  module V1
    module Admin
      class OrdersController < BaseController
        before_action :set_order, only: [ :show, :update ]

        def index
          orders = Order.includes(:user, :order_items).page(params[:page] || 1).per(params[:per_page] || 20)
          render json: orders.map { |order|
            {
              id: order.id,
              user: {
                id: order.user.id,
                email: order.user.email,
                full_name: order.user.full_name
              },
              status: order.status,
              total_amount: order.total_amount.to_f,
              items_count: order.order_items.count,
              created_at: order.created_at
            }
          }, status: :ok
        end

        def show
          render json: {
            id: @order.id,
            user: {
              id: @order.user.id,
              email: @order.user.email,
              full_name: @order.user.full_name
            },
            status: @order.status,
            total_amount: @order.total_amount.to_f,
            items: @order.order_items.includes(:product).map { |item|
              {
                id: item.id,
                product: {
                  id: item.product.id,
                  name: item.product.name
                },
                quantity: item.quantity,
                price: item.price.to_f
              }
            },
            created_at: @order.created_at,
            updated_at: @order.updated_at
          }, status: :ok
        end

        def update
          if @order.update(order_params)
            render json: {
              message: "Order updated successfully",
              order: {
                id: @order.id,
                status: @order.status
              }
            }, status: :ok
          else
            render json: {
              errors: @order.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        private

        def set_order
          @order = Order.find(params[:id])
        end

        def order_params
          params.require(:order).permit(:status)
        end
      end
    end
  end
end
