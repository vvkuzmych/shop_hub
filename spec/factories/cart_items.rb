FactoryBot.define do
  factory :cart_item do
    association :user
    association :product
    quantity { rand(1..5) }
    price { nil }
  end
end
