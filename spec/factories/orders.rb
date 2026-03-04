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

FactoryBot.define do
  factory :order do
    association :user
    status { :pending }

    after(:build) do |order|
      order.order_items << build(:order_item, order: order) if order.order_items.empty?
    end
  end
end
