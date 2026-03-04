class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :orders, dependent: :destroy
  has_many :reviews, dependent: :destroy
  # TODO: Uncomment when CartItem model is created
  # has_many :cart_items, dependent: :destroy

  # Enums (Rails 8 syntax)
  enum :role, { customer: 0, admin: 1 }

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, :last_name, presence: true

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :customers, -> { where(role: :customer) }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end
end
