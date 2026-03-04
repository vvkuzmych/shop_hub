class OrderItemSerializer
  include JSONAPI::Serializer

  attributes :quantity, :price

  belongs_to :order
  belongs_to :product

  attribute :price do |order_item|
    order_item.price.to_f
  end

  attribute :subtotal do |order_item|
    (order_item.quantity * order_item.price).to_f
  end
end
