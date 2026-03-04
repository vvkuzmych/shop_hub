FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    description { Faker::Lorem.paragraph }
    parent_id { nil }
    position { 1 }
  end
end
