# == Schema Information
#
# Table name: orders
#
#  id           :bigint           not null, primary key
#  status       :integer
#  total_amount :decimal(, )
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Polymorphic associations
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :addresses, as: :addressable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  # Enums (Rails 8 syntax)
  enum :status, { pending: 0, confirmed: 1, shipped: 2, delivered: 3, cancelled: 4 }

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  # Callbacks
  before_validation :calculate_total, on: :create
  after_create :send_confirmation_email

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }

  private

  def calculate_total
    self.total_amount = order_items.sum { |item| item.quantity * item.price }
  end

  def send_confirmation_email
    # OrderMailer.confirmation(self).deliver_later
  end
end
