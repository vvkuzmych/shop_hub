# == Schema Information
#
# Table name: orders
#
#  id                      :bigint           not null, primary key
#  delivery_address        :text
#  delivery_method         :integer          default("delivery"), not null
#  estimated_delivery_date :datetime
#  notes                   :text
#  payment_status          :integer          default("payment_unpaid"), not null
#  status                  :integer
#  total_amount            :decimal(, )
#  tracking_number         :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  payment_intent_id       :string
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_orders_on_payment_intent_id  (payment_intent_id)
#  index_orders_on_tracking_number    (tracking_number)
#  index_orders_on_user_id            (user_id)
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
  enum :status, {
    pending: 0,           # Order created, awaiting payment
    payment_received: 1,  # Payment confirmed
    processing: 2,        # Order being prepared
    packed: 3,            # Order packed, ready to ship
    shipped: 4,           # Order shipped/out for delivery
    out_for_delivery: 5,  # Order is with delivery partner
    delivered: 6,         # Order delivered to customer
    ready_for_pickup: 7,  # Order ready for customer pickup
    picked_up: 8,         # Customer picked up order
    cancelled: 9          # Order cancelled
  }

  enum :delivery_method, {
    delivery: 0,          # Home delivery
    pickup: 1,            # Store pickup
    nova_poshta: 2        # Nova Poshta (Ukrainian delivery service)
  }

  enum :payment_status, {
    payment_unpaid: 0,       # Payment not received
    payment_pending: 1,      # Payment processing
    payment_paid: 2,         # Payment successful
    payment_failed: 3,       # Payment failed
    payment_refunded: 4      # Payment refunded
  }

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
  validates :delivery_method, presence: true
  validates :payment_status, presence: true
  validates :delivery_address, presence: true, if: -> { delivery? || nova_poshta? }

  # Callbacks
  before_validation :calculate_total, on: :create
  after_create :send_confirmation_email
  after_update :send_status_update_email, if: :saved_change_to_status?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :paid, -> { where(payment_status: :payment_paid) }
  scope :unpaid, -> { where(payment_status: [ :payment_unpaid, :payment_pending ]) }

  # Public methods
  def can_be_cancelled?
    pending? || payment_received? || processing?
  end

  def next_status
    case status.to_sym
    when :pending then :payment_received
    when :payment_received then :processing
    when :processing then :packed
    when :packed then delivery? ? :shipped : :ready_for_pickup
    when :shipped then :out_for_delivery
    when :out_for_delivery then :delivered
    when :ready_for_pickup then :picked_up
    else nil
    end
  end

  def progress_percentage
    status_order = {
      pending: 0,
      payment_received: 15,
      processing: 30,
      packed: 50,
      shipped: 65,
      out_for_delivery: 80,
      delivered: 100,
      ready_for_pickup: 80,
      picked_up: 100,
      cancelled: 0
    }
    status_order[status.to_sym] || 0
  end

  private

  def calculate_total
    self.total_amount = order_items.sum { |item| item.quantity * item.price }
  end

  def send_confirmation_email
    OrderMailer.confirmation(self).deliver_later
  end

  def send_status_update_email
    OrderMailer.status_update(self).deliver_later
  end
end
