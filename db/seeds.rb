# Використання Ruby блоків та ітераторів

puts "🌱 Seeding database..."

# Clear existing data
[ User, Product, Category, Order, Review ].each(&:destroy_all)

# Create admin user
admin = User.create!(
  email: "admin@shophub.com",
  password: "password",
  first_name: "Admin",
  last_name: "User",
  role: :admin
)

# Create categories (з ієрархією)
electronics = Category.create!(name: "Electronics", description: "Electronic devices")
phones = Category.create!(name: "Phones", parent: electronics, description: "Mobile phones")
laptops = Category.create!(name: "Laptops", parent: electronics, description: "Laptop computers")

clothing = Category.create!(name: "Clothing", description: "Apparel")
mens = Category.create!(name: "Men's", parent: clothing)
womens = Category.create!(name: "Women's", parent: clothing)

# Create products (з блоками)
10.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10.0..500.0),
    stock: rand(0..100),
    category: [ phones, laptops, mens, womens ].sample,
    active: true
  )
end

# Create customers and orders
5.times do
  customer = User.create!(
    email: Faker::Internet.email,
    password: "password",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    role: :customer
  )

  # Create orders for each customer
  rand(1..3).times do
    order = customer.orders.build(
      status: [ :pending, :confirmed, :shipped ].sample
    )

    # Add items to order
    rand(1..5).times do
      product = Product.active.sample
      order.order_items.build(
        product: product,
        quantity: rand(1..3),
        price: product.price
      )
    end

    # Save order (calculate_total callback will set total_amount)
    order.save!
  end
end

puts "✅ Seeding complete!"
puts "   Users: #{User.count} (#{User.admins.count} admins)"
puts "   Categories: #{Category.count}"
puts "   Products: #{Product.count}"
puts "   Orders: #{Order.count}"
