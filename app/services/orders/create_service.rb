module Orders
  class CreateService
    # Service Object pattern для складної бізнес-логіки

    attr_reader :user, :items, :order, :errors

    def initialize(user:, items:)
      @user = user
      @items = items
      @errors = []
    end

    # Class method для виклику
    def self.call(user:, items:)
      new(user: user, items: items).call
    end

    def call
      ActiveRecord::Base.transaction do
        validate_items!
        create_order!
        create_order_items!
        update_stock!
        send_notifications!
      end

      self
    rescue StandardError => e
      @errors << e.message
      self
    end

    def success?
      errors.empty?
    end

    private

    def validate_items!
      raise "No items provided" if items.blank?

      items.each do |item|
        product = Product.find(item[:product_id])
        raise "#{product.name} is out of stock" unless product.stock >= item[:quantity]
      end
    end

    def create_order!
      @order = user.orders.create!(status: :pending)
    end

    def create_order_items!
      items.each do |item|
        product = Product.find(item[:product_id])

        @order.order_items.create!(
          product: product,
          quantity: item[:quantity],
          price: product.price
        )
      end
    end

    def update_stock!
      items.each do |item|
        product = Product.find(item[:product_id])
        product.decrement!(:stock, item[:quantity])
      end
    end

    def send_notifications!
      # Sidekiq background job
      OrderConfirmationJob.perform_later(@order.id)
    end
  end
end
