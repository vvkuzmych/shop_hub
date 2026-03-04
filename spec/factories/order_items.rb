FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { 2 }
    price { 19.99 }
  end
end
