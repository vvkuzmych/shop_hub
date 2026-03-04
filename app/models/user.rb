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
