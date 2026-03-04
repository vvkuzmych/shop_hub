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
class Address < ApplicationRecord
  # Polymorphic association - can belong to User, Order, etc.
  belongs_to :addressable, polymorphic: true

  # Enums for address types
  enum :address_type, {
    shipping: "shipping",
    billing: "billing",
    home: "home",
    work: "work"
  }, prefix: true

  # Validations
  validates :street, :city, :zip_code, :country, presence: true
  validates :address_type, inclusion: { in: address_types.keys }

  # Scopes
  scope :shipping_addresses, -> { where(address_type: :shipping) }
  scope :billing_addresses, -> { where(address_type: :billing) }
  scope :by_country, ->(country) { where(country: country) }

  # Methods
  def full_address
    [ street, city, state, zip_code, country ].compact.join(", ")
  end

  def to_s
    full_address
  end
end
