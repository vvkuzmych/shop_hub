FactoryBot.define do
  factory :order do
    user { nil }
    total_amount { "9.99" }
    status { 1 }
  end
end
