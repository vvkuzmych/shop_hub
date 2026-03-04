# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  description :text
#  featured    :boolean          default(FALSE), not null
#  name        :string
#  price       :decimal(, )
#  sku         :string
#  stock       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#
# Indexes
#
#  index_products_on_featured  (featured)
#  index_products_on_sku       (sku) UNIQUE
#

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
