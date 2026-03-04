class AddDeliveryAndPaymentFieldsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivery_method, :integer, default: 0, null: false
    add_column :orders, :payment_status, :integer, default: 0, null: false
    add_column :orders, :payment_intent_id, :string
    add_column :orders, :tracking_number, :string
    add_column :orders, :notes, :text
    add_column :orders, :delivery_address, :text
    add_column :orders, :estimated_delivery_date, :datetime

    add_index :orders, :payment_intent_id
    add_index :orders, :tracking_number
  end
end
