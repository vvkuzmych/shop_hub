module Orders
  class CreateService
    attr_reader :order, :errors

    def self.call(user:, items:, delivery_method: 'delivery', delivery_address: nil, notes: nil)
      new(user: user, items: items, delivery_method: delivery_method, 
          delivery_address: delivery_address, notes: notes).call
    end

    def initialize(user:, items:, delivery_method: 'delivery', delivery_address: nil, notes: nil)
      @user = user
      @items = items
      @delivery_method = delivery_method
      @delivery_address = delivery_address
      @notes = notes
      @order = nil
      @errors = []
    end

    def call
      ActiveRecord::Base.transaction do
        validate_items!
        create_order!
        create_order_items!
        clear_cart! if @clear_cart
        enqueue_confirmation_job
      end

      self
    rescue ActiveRecord::RecordInvalid, StandardError => e
      @errors << e.message
      self
    end

    def success?
      @errors.empty? && @order&.persisted?
    end

    private

    def validate_items!
      if @items.blank?
        @errors << "No items provided"
        raise StandardError, "No items provided"
      end
      
      if @delivery_method == 'delivery' && @delivery_address.blank?
        @errors << "Delivery address is required for delivery orders"
        raise StandardError, "Delivery address required"
      end
    end

    def create_order!
      @order = @user.orders.build(
        status: :pending,
        payment_status: :unpaid,
        delivery_method: @delivery_method,
        delivery_address: @delivery_address,
        notes: @notes
      )
    end

    def create_order_items!
      @items.each do |item_params|
        product = Product.find(item_params[:product_id])

        unless product.in_stock? && product.stock >= item_params[:quantity].to_i
          raise StandardError, "Product #{product.name} is out of stock"
        end

        @order.order_items.build(
          product: product,
          quantity: item_params[:quantity],
          price: product.price
        )

        # Decrease stock
        product.update!(stock: product.stock - item_params[:quantity].to_i)
      end

      @order.save!
    end

    def clear_cart!
      # Optional: clear cart items that were ordered
      product_ids = @items.map { |i| i[:product_id] }
      @user.cart_items.where(product_id: product_ids).destroy_all
    end

    def enqueue_confirmation_job
      OrderConfirmationJob.perform_later(@order.id) if @order.persisted?
    end
  end
end
