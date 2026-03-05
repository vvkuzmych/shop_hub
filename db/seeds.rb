# Використання Ruby блоків та ітераторів

puts "🌱 Seeding database..."

# Clear existing data
[ Comment, Attachment, Address, Review, Order, Product, Category, User ].each(&:destroy_all)

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
    delivery_method = [ :delivery, :pickup, :nova_poshta ].sample
    order = customer.orders.build(
      status: [ :pending, :payment_received, :shipped ].sample,
      delivery_method: delivery_method,
      payment_status: [ :payment_unpaid, :payment_paid ].sample,
      delivery_address: delivery_method == :pickup ? nil : "#{Faker::Address.street_address}, #{Faker::Address.city}, #{Faker::Address.state_abbr} #{Faker::Address.zip_code}"
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

# Create addresses for users
puts "📍 Creating addresses..."
User.all.each do |user|
  # Home address
  user.addresses.create!(
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    country: "USA",
    address_type: :home
  )

  # Shipping address (for customers)
  if user.customer?
    user.addresses.create!(
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::Address.state_abbr,
      zip_code: Faker::Address.zip_code,
      country: "USA",
      address_type: :shipping
    )
  end
end

# Create attachments for products
puts "📎 Creating attachments..."
Product.all.each do |product|
  # Product manual (PDF)
  product.attachments.create!(
    file_name: "#{product.name.parameterize}-manual.pdf",
    file_type: "pdf",
    file_size: rand(500_000..5_000_000),
    url: "https://cdn.shophub.com/manuals/#{product.id}.pdf"
  )

  # Product image
  rand(1..3).times do |i|
    product.attachments.create!(
      file_name: "#{product.name.parameterize}-image-#{i + 1}.jpg",
      file_type: "jpg",
      file_size: rand(100_000..1_000_000),
      url: "https://cdn.shophub.com/products/#{product.id}/image-#{i + 1}.jpg"
    )
  end
end

# Create comments for products
puts "💬 Creating comments..."
Product.all.each do |product|
  rand(0..5).times do
    customer = User.customers.sample
    product.comments.create!(
      content: Faker::Lorem.paragraph(sentence_count: rand(2..5)),
      user: customer
    )
  end
end

# Create comments for orders
Order.all.each do |order|
  if rand > 0.5
    order.comments.create!(
      content: Faker::Lorem.paragraph(sentence_count: rand(1..3)),
      user: order.user
    )
  end
end

# Create shipping addresses for orders
Order.where(status: [ :confirmed, :shipped, :delivered ]).each do |order|
  order.addresses.create!(
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    country: "USA",
    address_type: :shipping
  )
end

puts "✅ Seeding complete!"
puts "   Users: #{User.count} (#{User.admins.count} admins)"
puts "   Categories: #{Category.count}"
puts "   Products: #{Product.count}"
puts "   Orders: #{Order.count}"
puts "   Addresses: #{Address.count} (#{Address.shipping_addresses.count} shipping)"
puts "   Attachments: #{Attachment.count} (#{Attachment.images.count} images, #{Attachment.documents.count} docs)"
puts "   Comments: #{Comment.count} (#{Comment.for_product.count} on products, #{Comment.for_order.count} on orders)"
