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
class OrderSerializer
  include JSONAPI::Serializer

  attributes :status, :total_amount, :created_at, :updated_at,
             :delivery_method, :payment_status, :tracking_number,
             :notes, :delivery_address, :estimated_delivery_date

  belongs_to :user
  has_many :order_items

  attribute :total_amount do |order|
    order.total_amount.to_f
  end

  attribute :created_at do |order|
    order.created_at.iso8601
  end

  attribute :updated_at do |order|
    order.updated_at.iso8601
  end

  attribute :estimated_delivery_date do |order|
    order.estimated_delivery_date&.iso8601
  end

  attribute :progress_percentage do |order|
    order.progress_percentage
  end
end
