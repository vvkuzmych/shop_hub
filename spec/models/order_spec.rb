# == Schema Information
#
# Table name: orders
#
#  id                      :bigint           not null, primary key
#  delivery_address        :text
#  delivery_method         :integer          default("delivery"), not null
#  estimated_delivery_date :datetime
#  notes                   :text
#  payment_status          :integer          default("payment_unpaid"), not null
#  status                  :integer
#  total_amount            :decimal(, )
#  tracking_number         :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  payment_intent_id       :string
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_orders_on_payment_intent_id  (payment_intent_id)
#  index_orders_on_tracking_number    (tracking_number)
#  index_orders_on_user_id            (user_id)
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
    it do
      is_expected.to define_enum_for(:status).with_values(
        pending: 0,
        payment_received: 1,
        processing: 2,
        packed: 3,
        shipped: 4,
        out_for_delivery: 5,
        delivered: 6,
        ready_for_pickup: 7,
        picked_up: 8,
        cancelled: 9
      )
    end

    it do
      is_expected.to define_enum_for(:delivery_method).with_values(
        delivery: 0,
        pickup: 1,
        nova_poshta: 2
      )
    end

    it do
      is_expected.to define_enum_for(:payment_status).with_values(
        payment_unpaid: 0,
        payment_pending: 1,
        payment_paid: 2,
        payment_failed: 3,
        payment_refunded: 4
      )
    end
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

        order = Order.new(
          user: user,
          status: :pending,
          delivery_method: :delivery,
          payment_status: :payment_unpaid,
          delivery_address: "123 Test St, Test City"
        )
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
      expect(order.payment_received?).to be false
      expect(order.shipped?).to be false
    end

    it "provides delivery method query methods" do
      order = create(:order, delivery_method: :delivery)

      expect(order.delivery?).to be true
      expect(order.pickup?).to be false
      expect(order.nova_poshta?).to be false
    end

    it "provides payment status query methods" do
      order = create(:order, payment_status: :payment_unpaid)

      expect(order.payment_unpaid?).to be true
      expect(order.payment_paid?).to be false
    end
  end
end
