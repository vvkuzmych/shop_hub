FactoryBot.define do
  factory :product do
    association :category

    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    price { Faker::Commerce.price(range: 10.0..500.0) }
    stock { rand(0..100) }
    sku { Faker::Code.unique.asin }
    active { true }

    trait :out_of_stock do
      stock { 0 }
    end

    trait :inactive do
      active { false }
    end
  end
end
