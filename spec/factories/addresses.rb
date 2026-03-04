# == Schema Information
#
# Table name: addresses
#
#  id               :bigint           not null, primary key
#  address_type     :string
#  addressable_type :string           not null
#  city             :string           not null
#  country          :string           default("USA"), not null
#  state            :string
#  street           :string           not null
#  zip_code         :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :bigint           not null
#
# Indexes
#
#  index_addresses_on_address_type                         (address_type)
#  index_addresses_on_addressable                          (addressable_type,addressable_id)
#  index_addresses_on_addressable_type_and_addressable_id  (addressable_type,addressable_id)
#
FactoryBot.define do
  factory :address do
    street { Faker::Address.street_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip_code }
    country { "USA" }
    address_type { :shipping }
    association :addressable, factory: :user

    trait :shipping do
      address_type { :shipping }
    end

    trait :billing do
      address_type { :billing }
    end

    trait :home do
      address_type { :home }
    end

    trait :work do
      address_type { :work }
    end

    trait :for_user do
      association :addressable, factory: :user
    end

    trait :for_order do
      association :addressable, factory: :order
    end

    trait :international do
      country { Faker::Address.country }
    end
  end
end
