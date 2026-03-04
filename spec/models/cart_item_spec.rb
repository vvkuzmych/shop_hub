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

RSpec.describe CartItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:product) }
  end

  describe "validations" do
    subject { build(:cart_item) }

    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:user_id) }

    it "requires price after callback" do
      cart_item = build(:cart_item, product: nil, price: nil)
      expect(cart_item).not_to be_valid
      expect(cart_item.errors[:price]).to include("can't be blank")
    end
  end

  describe "callbacks" do
    describe "#set_price" do
      it "sets price from product on create" do
        product = create(:product, price: 29.99)
        cart_item = build(:cart_item, product: product, price: nil)

        cart_item.save
        expect(cart_item.price).to eq(29.99)
      end

      it "does not override manually set price" do
        product = create(:product, price: 29.99)
        cart_item = build(:cart_item, product: product, price: 19.99)

        cart_item.save
        expect(cart_item.price).to eq(19.99)
      end
    end
  end

  describe "#subtotal" do
    it "calculates subtotal correctly" do
      cart_item = create(:cart_item, quantity: 3, price: 10.00)
      expect(cart_item.subtotal).to eq(30.00)
    end
  end
end
