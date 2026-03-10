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
require "rails_helper"

RSpec.describe CartItemSerializer do
  describe ".format" do
    let(:product) { create(:product, name: "Test Product", price: 25.99, stock: 10) }
    let(:cart_item) do
      build(:cart_item, product: product, quantity: 2, price: 25.99)
    end

    it "formats a single cart item correctly" do
      result = described_class.format(cart_item)

      expect(result).to include(
        id: cart_item.id,
        product_id: product.id,
        product_name: "Test Product",
        quantity: 2,
        price: 25.99,
        stock: 10
      )
      expect(result[:subtotal]).to eq(51.98)
    end
  end

  describe ".format_collection" do
    let(:product1) { create(:product, name: "Product 1", price: 10.00, stock: 5) }
    let(:product2) { create(:product, name: "Product 2", price: 20.00, stock: 8) }
    let(:cart_items) do
      [
        build(:cart_item, product: product1, quantity: 1, price: 10.00),
        build(:cart_item, product: product2, quantity: 2, price: 20.00)
      ]
    end

    it "formats multiple cart items" do
      result = described_class.format_collection(cart_items)

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:product_name]).to eq("Product 1")
      expect(result.second[:product_name]).to eq("Product 2")
    end
  end

  describe ".format_cart" do
    let(:product1) { create(:product, price: 15.50, stock: 3) }
    let(:product2) { create(:product, price: 30.00, stock: 7) }
    let(:cart_items) do
      [
        build(:cart_item, product: product1, quantity: 2, price: 15.50),
        build(:cart_item, product: product2, quantity: 1, price: 30.00)
      ]
    end

    it "formats cart with items and total" do
      result = described_class.format_cart(cart_items)

      expect(result).to have_key(:cart_items)
      expect(result).to have_key(:total)
      expect(result[:cart_items].size).to eq(2)
      expect(result[:total]).to eq(61.00)
    end

    it "includes message when provided" do
      result = described_class.format_cart(cart_items, message: "Cart updated")

      expect(result[:message]).to eq("Cart updated")
    end

    it "does not include message when not provided" do
      result = described_class.format_cart(cart_items)

      expect(result).not_to have_key(:message)
    end
  end
end
