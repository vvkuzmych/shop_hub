# Seed data for Order Tracking - Creates orders in each status phase
# Run with: rails runner db/seeds_order_tracking.rb

puts "🚚 Creating Order Tracking Sample Data..."

# Find or create admin user
admin = User.find_or_create_by!(email: "admin@shophub.com") do |user|
  user.password = "password123"
  user.first_name = "Admin"
  user.last_name = "User"
  user.role = :admin
end

# Find or create test customer
customer = User.find_or_create_by!(email: "customer@test.com") do |user|
  user.password = "password123"
  user.first_name = "John"
  user.last_name = "Customer"
  user.role = :customer
end

# Ensure we have products
if Product.count == 0
  puts "❌ No products found. Please run: rails db:seed first"
  exit
end

products = Product.active.limit(5).to_a

# Delete existing test orders for this customer
customer.orders.destroy_all

puts "\n📦 Creating orders in different statuses...\n"

# Helper to create order with items
def create_order_with_items(user, products, status_name, attributes = {})
  # Select products and prepare items
  selected_products = products.sample(rand(2..3))
  items_array = selected_products.map do |product|
    { product_id: product.id, quantity: rand(1..3) }
  end

  # Use the Orders::CreateService
  service = Orders::CreateService.call(
    user: user,
    items: items_array,
    delivery_method: (attributes[:delivery_method] || 'delivery').to_s,
    delivery_address: attributes[:delivery_address],
    notes: attributes[:notes]
  )

  order = service.order

  # Update order with additional attributes
  order.update!(
    status: status_name,
    payment_status: attributes[:payment_status] || :payment_unpaid,
    tracking_number: attributes[:tracking_number],
    estimated_delivery_date: attributes[:estimated_delivery_date],
    payment_intent_id: attributes[:payment_intent_id]
  )

  order
end

# 1. ORDER PLACED (pending)
order1 = create_order_with_items(customer, products, :pending,
  payment_status: :payment_unpaid,
  delivery_method: :delivery,
  delivery_address: "123 Main St, New York, NY 10001",
  notes: "Please ring doorbell"
)
puts "✅ Order ##{order1.id} - PENDING (Order Placed)"

# 2. PAYMENT RECEIVED
order2 = create_order_with_items(customer, products, :payment_received,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "456 Oak Ave, Brooklyn, NY 11201",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}"
)
puts "✅ Order ##{order2.id} - PAYMENT RECEIVED"

# 3. PROCESSING
order3 = create_order_with_items(customer, products, :processing,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "789 Elm St, Queens, NY 11354",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}"
)
puts "✅ Order ##{order3.id} - PROCESSING"

# 4. PACKED
order4 = create_order_with_items(customer, products, :packed,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "321 Pine Rd, Bronx, NY 10451",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  tracking_number: "TRK#{rand(100000..999999)}"
)
puts "✅ Order ##{order4.id} - PACKED"

# 5. SHIPPED
order5 = create_order_with_items(customer, products, :shipped,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "555 Maple Dr, Manhattan, NY 10002",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  tracking_number: "TRK#{rand(100000..999999)}",
  estimated_delivery_date: 2.days.from_now
)
puts "✅ Order ##{order5.id} - SHIPPED"

# 6. OUT FOR DELIVERY
order6 = create_order_with_items(customer, products, :out_for_delivery,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "888 Cedar Ln, Staten Island, NY 10301",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  tracking_number: "TRK#{rand(100000..999999)}",
  estimated_delivery_date: Time.current
)
puts "✅ Order ##{order6.id} - OUT FOR DELIVERY"

# 7. DELIVERED
order7 = create_order_with_items(customer, products, :delivered,
  payment_status: :payment_paid,
  delivery_method: :delivery,
  delivery_address: "999 Birch Way, Long Island, NY 11553",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  tracking_number: "TRK#{rand(100000..999999)}",
  estimated_delivery_date: 1.day.ago
)
puts "✅ Order ##{order7.id} - DELIVERED"

# 7B. NOVA POSHTA SHIPPED (Ukrainian delivery service)
order7b = create_order_with_items(customer, products, :shipped,
  payment_status: :payment_paid,
  delivery_method: :nova_poshta,
  delivery_address: "Nova Poshta\nCity: Kyiv\nWarehouse: Branch #42\nPhone: +380501234567",
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  tracking_number: "NP#{rand(10000000000..99999999999)}",
  estimated_delivery_date: 3.days.from_now,
  notes: "Nova Poshta delivery to warehouse"
)
puts "✅ Order ##{order7b.id} - NOVA POSHTA SHIPPED"

# 8. READY FOR PICKUP (Store pickup scenario)
order8 = create_order_with_items(customer, products, :ready_for_pickup,
  payment_status: :payment_paid,
  delivery_method: :pickup,
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  notes: "Store: Manhattan Location, 123 Store Ave"
)
puts "✅ Order ##{order8.id} - READY FOR PICKUP"

# 9. PICKED UP (Store pickup completed)
order9 = create_order_with_items(customer, products, :picked_up,
  payment_status: :payment_paid,
  delivery_method: :pickup,
  payment_intent_id: "pi_#{SecureRandom.hex(12)}",
  notes: "Picked up from Brooklyn Store"
)
puts "✅ Order ##{order9.id} - PICKED UP"

puts "\n" + "="*60
puts "✨ Order Tracking Sample Data Created Successfully!"
puts "="*60
puts "\n📊 Summary:"
puts "  Customer: #{customer.email}"
puts "  Total Orders: #{customer.orders.count}"
puts "\n📦 Order IDs by Status:"
puts "  1. Pending (Order Placed):     ##{order1.id}"
puts "  2. Payment Received:           ##{order2.id}"
puts "  3. Processing:                 ##{order3.id}"
puts "  4. Packed:                     ##{order4.id}"
puts "  5. Shipped:                    ##{order5.id}"
puts "  6. Out for Delivery:           ##{order6.id}"
puts "  7. Delivered:                  ##{order7.id}"
puts "  8. Ready for Pickup:           ##{order8.id}"
puts "  9. Picked Up:                  ##{order9.id}"
puts "\n🔐 Login Credentials:"
puts "  Email:    customer@test.com"
puts "  Password: password123"
puts "\n🌐 Test URLs (after login):"
puts "  Orders List:  http://localhost:5173/orders"
puts "  Track Order:  http://localhost:5173/orders/{id}/track"
puts "  Example:      http://localhost:5173/orders/#{order5.id}/track"
puts "\n" + "="*60
