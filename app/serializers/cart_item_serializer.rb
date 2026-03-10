# == Schema Information
#
# Table name: cart_items
#
#  id         :bigint           not null, primary key
#  price      :decimal(10, 2)
#  quantity   :integer          default(1), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_cart_items_on_product_id              (product_id)
#  index_cart_items_on_user_id                 (user_id)
#  index_cart_items_on_user_id_and_product_id  (user_id,product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
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
