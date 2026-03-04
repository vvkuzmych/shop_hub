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
class OrderSerializer
  include JSONAPI::Serializer

  attributes :status, :total_amount, :created_at, :updated_at

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
end
