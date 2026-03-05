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
