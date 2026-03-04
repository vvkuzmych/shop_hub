FactoryBot.define do
  factory :order do
    association :user
    status { :pending }

    after(:build) do |order|
      order.order_items << build(:order_item, order: order) if order.order_items.empty?
    end
  end
end
