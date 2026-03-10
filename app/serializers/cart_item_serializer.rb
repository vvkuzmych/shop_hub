class CartItemSerializer
  def self.format(item)
    {
      id: item.id,
      product_id: item.product_id,
      product_name: item.product.name,
      quantity: item.quantity,
      price: item.price.to_f,
      subtotal: item.subtotal.to_f,
      stock: item.product.stock
    }
  end

  def self.format_collection(items)
    items.map { |item| format(item) }
  end

  def self.format_cart(items, message: nil)
    result = {
      cart_items: format_collection(items),
      total: items.sum(&:subtotal).to_f
    }
    result[:message] = message if message.present?
    result
  end
end
