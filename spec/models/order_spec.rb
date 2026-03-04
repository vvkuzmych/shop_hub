# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  status       :integer
#  total_amount :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require "rails_helper"

RSpec.describe Order, type: :model do
  # Association tests
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:order_items).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:order_items) }
  end

  # Enum tests
  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, confirmed: 1, shipped: 2, delivered: 3, cancelled: 4) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:status) }

    it "validates total_amount is positive after calculation" do
      order = build(:order)
      expect(order).to be_valid
      expect(order.total_amount).to be > 0
    end

    it "is invalid when total_amount would be zero or negative" do
      order = build(:order)
      order.order_items.clear
      order.valid?
      expect(order.errors[:total_amount]).to include("must be greater than 0")
    end
  end

  # Scope tests
  describe "scopes" do
    describe ".recent" do
      it "returns orders ordered by created_at desc" do
        order1 = create(:order, created_at: 3.days.ago)
        order2 = create(:order, created_at: 1.day.ago)
        order3 = create(:order, created_at: 2.days.ago)

        expect(Order.recent).to eq([ order2, order3, order1 ])
      end
    end

    describe ".by_status" do
      it "returns orders filtered by status" do
        pending_order = create(:order, status: :pending)
        shipped_order = create(:order, status: :shipped)

        expect(Order.by_status(:pending)).to include(pending_order)
        expect(Order.by_status(:pending)).not_to include(shipped_order)
      end
    end
  end

  # Callback tests
  describe "callbacks" do
    describe "#calculate_total" do
      it "calculates total_amount from order_items before create" do
        user = create(:user)
        product1 = create(:product, price: 10.00)
        product2 = create(:product, price: 20.00)

        order = Order.new(user: user, status: :pending)
        order.order_items.build(product: product1, quantity: 2, price: 10.00)
        order.order_items.build(product: product2, quantity: 1, price: 20.00)

        order.save!

        expect(order.total_amount).to eq(40.00)
      end
    end
  end

  # Status helper methods
  describe "status helpers" do
    it "provides status query methods" do
      order = create(:order, status: :pending)

      expect(order.pending?).to be true
      expect(order.confirmed?).to be false
      expect(order.shipped?).to be false
    end
  end
end
