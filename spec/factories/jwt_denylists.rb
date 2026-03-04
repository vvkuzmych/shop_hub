# == Schema Information
#
# Table name: jwt_denylists
#
#  id         :bigint           not null, primary key
#  exp        :datetime
#  jti        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_jwt_denylists_on_jti  (jti)
#

FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2026-03-04 12:28:31" }
  end
end
