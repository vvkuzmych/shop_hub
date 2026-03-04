FactoryBot.define do
  factory :review do
    user { nil }
    product { nil }
    rating { 1 }
    comment { "MyText" }
  end
end
