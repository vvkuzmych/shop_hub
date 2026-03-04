# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string
#  encrypted_password     :string
#  first_name             :string
#  last_name              :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  # Enums (Rails 8 syntax)
  enum :role, { customer: 0, admin: 1 }

  # Validations (email is handled by Devise :validatable)
  validates :first_name, :last_name, presence: true

  # Default role
  after_initialize :set_default_role, if: :new_record?

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def set_default_role
    self.role ||= :customer
  end
end
