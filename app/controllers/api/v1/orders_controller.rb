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
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Order not found" }, status: :not_found
      end

      # POST /api/v1/orders
      def create
        # Використати Service Object для складної бізнес-логіки
        result = Orders::CreateService.call(
          user: current_user,
          items: params[:items],
          delivery_method: params[:delivery_method],
          delivery_address: params[:delivery_address],
          notes: params[:notes]
        )

        if result.success?
          render json: OrderSerializer.new(result.order).serializable_hash, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/orders/:id/track
      def track
        @order = current_user.orders.find(params[:id])
        
        render json: {
          data: {
            id: @order.id,
            status: @order.status,
            payment_status: @order.payment_status,
            delivery_method: @order.delivery_method,
            tracking_number: @order.tracking_number,
            estimated_delivery_date: @order.estimated_delivery_date,
            progress_percentage: @order.progress_percentage,
            total_amount: @order.total_amount,
            created_at: @order.created_at,
            updated_at: @order.updated_at
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Order not found" }, status: :not_found
      end

      # PATCH /api/v1/orders/:id/cancel
      def cancel
        @order = current_user.orders.find(params[:id])

        if @order.pending? && @order.update(status: :cancelled)
          render json: OrderSerializer.new(@order).serializable_hash
        else
          render json: { error: "Cannot cancel this order" }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Order not found" }, status: :not_found
      end
    end
  end
end
