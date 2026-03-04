require "rails_helper"

RSpec.describe OrderItem, type: :model do
  # Association tests
  describe "associations" do
    it { is_expected.to belong_to(:order) }
    it { is_expected.to belong_to(:product) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }
  end

  # Callback tests
  describe "callbacks" do
    describe "#set_price" do
      it "sets price from product price on create when price is nil" do
        product = create(:product, price: 99.99)
        order = create(:order)
        order_item = OrderItem.new(order: order, product: product, quantity: 2)

        expect(order_item.price).to be_nil
        order_item.save!
        expect(order_item.price).to eq(99.99)
      end

      it "does not override price if already set" do
        product = create(:product, price: 99.99)
        order = create(:order)
        order_item = OrderItem.create!(order: order, product: product, quantity: 2, price: 79.99)

        expect(order_item.price).to eq(79.99)
      end
    end
  end
end
