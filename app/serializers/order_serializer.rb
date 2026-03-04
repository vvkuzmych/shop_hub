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
