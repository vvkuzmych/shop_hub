class OrderMailer < ApplicationMailer
  default from: 'orders@shophub.com'

  def confirmation(order)
    @order = order
    @user = order.user
    @order_items = order.order_items.includes(:product)
    
    mail(
      to: @user.email,
      subject: "Order Confirmation ##{@order.id} - ShopHub"
    )
  end

  def status_update(order)
    @order = order
    @user = order.user
    @status = order.status.humanize
    @tracking_url = "#{ENV['FRONTEND_URL']}/orders/#{order.id}/track"
    
    mail(
      to: @user.email,
      subject: "Order ##{@order.id} - #{@status}"
    )
  end
end
