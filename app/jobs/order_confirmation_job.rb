class OrderConfirmationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.includes(:user, order_items: :product).find(order_id)

    # TODO: Uncomment when OrderMailer is implemented
    # OrderMailer.confirmation(order).deliver_now

    # TODO: Uncomment when AnalyticsService is implemented
    # AnalyticsService.track_order(order)

    Rails.logger.info "Order confirmation job completed for Order ##{order.id}"
  end
end
