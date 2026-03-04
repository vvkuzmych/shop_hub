FactoryBot.define do
  factory :review do
    association :user
    association :product
    rating { rand(1..5) }
    comment { Faker::Lorem.sentence(word_count: 15) }
  end
end
