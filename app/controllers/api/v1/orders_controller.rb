module Api
  module V1
    class OrdersController < BaseController
      # GET /api/v1/orders
      def index
        @orders = current_user.orders.includes(:order_items).recent

        render json: OrderSerializer.new(@orders, {
          include: [ :order_items ]
        }).serializable_hash
      end

      # GET /api/v1/orders/:id
      def show
        @order = current_user.orders.includes(order_items: :product).find(params[:id])

        render json: OrderSerializer.new(@order, {
          include: [ :order_items, "order_items.product" ]
        }).serializable_hash
      end

      # POST /api/v1/orders
      def create
        # Використати Service Object для складної бізнес-логіки
        result = Orders::CreateService.call(
          user: current_user,
          items: params[:items]
        )

        if result.success?
          render json: OrderSerializer.new(result.order).serializable_hash, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/orders/:id/cancel
      def cancel
        @order = current_user.orders.find(params[:id])

        if @order.pending? && @order.update(status: :cancelled)
          render json: OrderSerializer.new(@order).serializable_hash
        else
          render json: { error: "Cannot cancel this order" }, status: :unprocessable_entity
        end
      end
    end
  end
end
