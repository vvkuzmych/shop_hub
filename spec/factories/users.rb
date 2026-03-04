FactoryBot.define do
  factory :user do
    email { "MyString" }
    password_digest { "MyString" }
    role { 1 }
    first_name { "MyString" }
    last_name { "MyString" }
  end
end
