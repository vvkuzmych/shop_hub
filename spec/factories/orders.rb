# == Schema Information
#
# Table name: orders
#
#  id                      :bigint           not null, primary key
#  delivery_address        :text
#  delivery_method         :integer          default("delivery"), not null
#  estimated_delivery_date :datetime
#  notes                   :text
#  payment_status          :integer          default("unpaid"), not null
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

FactoryBot.define do
  factory :order do
    association :user
    status { :pending }

    after(:build) do |order|
      order.order_items << build(:order_item, order: order) if order.order_items.empty?
    end
  end
end
