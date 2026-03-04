FactoryBot.define do
  factory :category do
    name { "MyString" }
    description { "MyText" }
    parent_id { 1 }
    position { 1 }
  end
end
