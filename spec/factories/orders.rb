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
FactoryBot.define do
  factory :order do
    association :user
    status { :pending }
    delivery_method { :delivery }
    payment_status { :payment_unpaid }
    delivery_address { "123 Test Street, Test City, TS 12345" }

    after(:build) do |order|
      order.order_items << build(:order_item, order: order) if order.order_items.empty?
    end

    trait :with_payment do
      payment_status { :payment_paid }
      payment_intent_id { "pi_test_#{SecureRandom.hex(12)}" }
    end

    trait :shipped do
      status { :shipped }
      payment_status { :payment_paid }
      tracking_number { "TRK#{rand(100000..999999)}" }
    end

    trait :delivered do
      status { :delivered }
      payment_status { :payment_paid }
      tracking_number { "TRK#{rand(100000..999999)}" }
    end

    trait :pickup do
      delivery_method { :pickup }
      delivery_address { nil }
    end

    trait :nova_poshta do
      delivery_method { :nova_poshta }
      delivery_address { "Nova Poshta\nТип: Відділення\nМісто: Київ\nВідділення №1\nТелефон: +380501234567" }
    end
  end
end
