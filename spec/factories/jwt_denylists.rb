FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2026-03-04 12:28:31" }
  end
end
