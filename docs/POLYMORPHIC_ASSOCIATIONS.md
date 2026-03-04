# Polymorphic Associations in ShopHub

This document explains the three polymorphic associations implemented in ShopHub: Comments, Addresses, and Attachments.

## Table of Contents

- [Overview](#overview)
- [1. Comments](#1-comments)
- [2. Addresses](#2-addresses)
- [3. Attachments](#3-attachments)
- [Database Schema](#database-schema)
- [Usage Examples](#usage-examples)
- [Testing](#testing)

---

## Overview

Polymorphic associations allow a model to belong to more than one other model on a single association. This is useful when multiple models share similar functionality.

### What We Implemented

1. **Comments** - Can be added to Products and Orders
2. **Addresses** - Can be associated with Users and Orders
3. **Attachments** - Can be attached to Products, Users, and Orders

---

## 1. Comments

Comments provide a way for users to leave feedback on products or orders.

### Model: `Comment`

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user
end
```

### Associations

- **Product** has_many :comments
- **Order** has_many :comments
- **User** has_many :comments (as author)

### Database Columns

| Column | Type | Description |
|--------|------|-------------|
| content | text | Comment text (10-2000 chars) |
| commentable_type | string | Type of model (Product/Order) |
| commentable_id | bigint | ID of the model |
| user_id | bigint | Author of comment |
| created_at | datetime | Timestamp |
| updated_at | datetime | Timestamp |

### Features

- **Validations:**
  - Content: 10-2000 characters
  - Commentable type: Product or Order only

- **Scopes:**
  - `.recent` - Most recent first
  - `.for_product` - Only product comments
  - `.for_order` - Only order comments

- **Methods:**
  - `author_name` - Returns user's full name

### Usage Examples

```ruby
# Add comment to a product
product = Product.find(1)
comment = product.comments.create!(
  content: "Great product! Highly recommend.",
  user: current_user
)

# Add comment to an order
order = Order.find(1)
comment = order.comments.create!(
  content: "Fast delivery, thanks!",
  user: current_user
)

# Get all comments for a product
product.comments.recent

# Get user's comments
user.comments
```

---

## 2. Addresses

Addresses provide flexible location data for users and orders.

### Model: `Address`

```ruby
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true
  enum :address_type, {
    shipping: "shipping",
    billing: "billing",
    home: "home",
    work: "work"
  }, prefix: true
end
```

### Associations

- **User** has_many :addresses
- **Order** has_many :addresses

### Database Columns

| Column | Type | Description |
|--------|------|-------------|
| street | string | Street address |
| city | string | City name |
| state | string | State/Province |
| zip_code | string | Postal code |
| country | string | Country (default: USA) |
| address_type | string | Type enum |
| addressable_type | string | Model type |
| addressable_id | bigint | Model ID |
| created_at | datetime | Timestamp |
| updated_at | datetime | Timestamp |

### Features

- **Validations:**
  - Required: street, city, zip_code, country
  - Address type must be valid enum value

- **Enums:**
  - `shipping`, `billing`, `home`, `work`
  - Prefix methods: `address_type_shipping?`, etc.

- **Scopes:**
  - `.shipping_addresses` - Only shipping
  - `.billing_addresses` - Only billing
  - `.by_country(country)` - Filter by country

- **Methods:**
  - `full_address` - Complete formatted address
  - `to_s` - Returns full address

### Usage Examples

```ruby
# Add shipping address to user
user = User.find(1)
address = user.addresses.create!(
  street: "123 Main St",
  city: "New York",
  state: "NY",
  zip_code: "10001",
  country: "USA",
  address_type: :shipping
)

# Add shipping address to order
order = Order.find(1)
order.addresses.create!(
  street: "456 Oak Ave",
  city: "Los Angeles",
  state: "CA",
  zip_code: "90001",
  country: "USA",
  address_type: :shipping
)

# Get user's shipping addresses
user.addresses.shipping_addresses

# Check address type
address.address_type_shipping? # => true

# Get formatted address
address.full_address
# => "123 Main St, New York, NY, 10001, USA"
```

---

## 3. Attachments

Attachments provide a flexible file storage system for various models.

### Model: `Attachment`

```ruby
class Attachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
end
```

### Associations

- **Product** has_many :attachments
- **User** has_many :attachments
- **Order** has_many :attachments

### Database Columns

| Column | Type | Description |
|--------|------|-------------|
| file_name | string | Name of file |
| file_type | string | File extension |
| file_size | integer | Size in bytes |
| url | string | File URL/path |
| attachable_type | string | Model type |
| attachable_id | bigint | Model ID |
| created_at | datetime | Timestamp |
| updated_at | datetime | Timestamp |

### Features

- **Validations:**
  - File name required
  - File size must be positive

- **File Type Constants:**
  - `IMAGE_TYPES`: jpg, jpeg, png, gif, webp
  - `DOCUMENT_TYPES`: pdf, doc, docx, txt
  - `VIDEO_TYPES`: mp4, avi, mov

- **Scopes:**
  - `.images` - Only images
  - `.documents` - Only documents
  - `.videos` - Only videos
  - `.recent` - Most recent first

- **Methods:**
  - `image?` - Check if image
  - `document?` - Check if document
  - `video?` - Check if video
  - `file_size_human` - Human-readable size

### Usage Examples

```ruby
# Add attachment to product
product = Product.find(1)
attachment = product.attachments.create!(
  file_name: "manual.pdf",
  file_type: "pdf",
  file_size: 2_500_000,
  url: "https://cdn.example.com/manuals/product1.pdf"
)

# Add attachment to user (profile picture)
user = User.find(1)
user.attachments.create!(
  file_name: "avatar.jpg",
  file_type: "jpg",
  file_size: 150_000,
  url: "https://cdn.example.com/avatars/user1.jpg"
)

# Get all product images
product.attachments.images

# Check file type
attachment.document? # => true

# Get human-readable file size
attachment.file_size_human
# => "2.38 MB"

# Auto-extract from URL
attachment = Attachment.new(
  url: "https://example.com/files/doc.pdf",
  attachable: product
)
attachment.save!
# file_name => "doc.pdf"
# file_type => "pdf"
```

---

## Database Schema

### Polymorphic Columns Pattern

All three tables follow the same polymorphic pattern:

```ruby
t.references :xxx_able, polymorphic: true, null: false
```

This creates two columns:
- `xxx_able_type` (string) - Stores the model class name
- `xxx_able_id` (bigint) - Stores the record ID

### Indexes

Each polymorphic table has:
- Composite index on `[type, id]` for fast lookups
- Additional indexes on frequently queried columns

```sql
-- Comments
CREATE INDEX index_comments_on_commentable_type_and_commentable_id
  ON comments (commentable_type, commentable_id);

-- Addresses  
CREATE INDEX index_addresses_on_addressable_type_and_addressable_id
  ON addresses (addressable_type, addressable_id);
CREATE INDEX index_addresses_on_address_type
  ON addresses (address_type);

-- Attachments
CREATE INDEX index_attachments_on_attachable_type_and_attachable_id
  ON attachments (attachable_type, attachable_id);
CREATE INDEX index_attachments_on_file_type
  ON attachments (file_type);
```

---

## Usage Examples

### Console Examples

```ruby
# Rails console examples

# 1. Comments
product = Product.first
product.comments.create!(
  content: "This is a great product!",
  user: User.first
)
product.comments.count # => 1
product.comments.recent.first.author_name # => "John Doe"

# 2. Addresses
user = User.first
user.addresses.create!(
  street: "123 Main St",
  city: "NYC",
  zip_code: "10001",
  country: "USA",
  address_type: :home
)
user.addresses.shipping_addresses # => []
user.addresses.first.full_address # => "123 Main St, NYC, 10001, USA"

# 3. Attachments
product = Product.first
product.attachments.create!(
  file_name: "spec_sheet.pdf",
  file_type: "pdf",
  file_size: 1_024_000
)
product.attachments.documents.count # => 1
product.attachments.first.file_size_human # => "1.0 MB"
```

### Migration Examples

```ruby
# Add comment to existing product
product = Product.find_by(name: "Laptop")
product.comments.create!(
  content: "Excellent laptop for development work!",
  user: User.find_by(email: "admin@shophub.com")
)

# Bulk create addresses for users
User.all.each do |user|
  user.addresses.create!(
    street: Faker::Address.street_address,
    city: Faker::Address.city,
    state: Faker::Address.state_abbr,
    zip_code: Faker::Address.zip_code,
    country: "USA",
    address_type: :home
  )
end

# Add product manuals
Product.all.each do |product|
  product.attachments.create!(
    file_name: "#{product.name.parameterize}-manual.pdf",
    file_type: "pdf",
    file_size: rand(500_000..5_000_000),
    url: "https://cdn.example.com/manuals/#{product.id}.pdf"
  )
end
```

---

## Testing

### Test Coverage

All polymorphic models have comprehensive test coverage:

- **Comment**: 12 examples
- **Address**: 14 examples  
- **Attachment**: 21 examples

**Total**: 47 new tests, all passing ✅

### Running Tests

```bash
# Test all polymorphic models
bundle exec rspec spec/models/comment_spec.rb \
                   spec/models/address_spec.rb \
                   spec/models/attachment_spec.rb

# Test specific model
bundle exec rspec spec/models/comment_spec.rb

# Test with documentation format
bundle exec rspec spec/models/ --format documentation
```

### Factory Usage

```ruby
# Using FactoryBot in tests

# Create comment for product
comment = create(:comment, :for_product, user: user)

# Create shipping address for user
address = create(:address, :shipping, :for_user)

# Create image attachment for product
attachment = create(:attachment, :image, :for_product)

# Traits available:
# Comments: :for_product, :for_order, :short, :long
# Addresses: :shipping, :billing, :home, :work, :for_user, :for_order
# Attachments: :image, :document, :video, :for_product, :for_user, :for_order
```

---

## API Integration (Future)

### Suggested API Endpoints

```ruby
# Comments
POST   /api/v1/products/:id/comments
GET    /api/v1/products/:id/comments
POST   /api/v1/orders/:id/comments
GET    /api/v1/orders/:id/comments

# Addresses
POST   /api/v1/users/:id/addresses
GET    /api/v1/users/:id/addresses
PATCH  /api/v1/addresses/:id
DELETE /api/v1/addresses/:id

# Attachments
POST   /api/v1/products/:id/attachments
GET    /api/v1/products/:id/attachments
DELETE /api/v1/attachments/:id
```

---

## Benefits of Polymorphic Associations

### 1. **Code Reusability**
- Single Comment model serves multiple purposes
- DRY principle - don't repeat comment logic

### 2. **Flexibility**
- Easy to add new commentable models
- Just add `has_many :comments, as: :commentable`

### 3. **Maintainability**
- Changes to comment logic in one place
- Consistent behavior across models

### 4. **Database Efficiency**
- Fewer tables to manage
- Composite indexes for fast lookups

### 5. **Scalability**
- Easy to extend to new models
- No schema changes needed to add new associations

---

## Best Practices

### 1. **Validate Polymorphic Type**
```ruby
validates :commentable_type, inclusion: { in: %w[Product Order] }
```

### 2. **Use Scopes for Type Filtering**
```ruby
scope :for_product, -> { where(commentable_type: "Product") }
```

### 3. **Add Composite Indexes**
```ruby
add_index :comments, [:commentable_type, :commentable_id]
```

### 4. **Eager Load to Avoid N+1**
```ruby
Product.includes(:comments).all
```

### 5. **Use STI for Similar Models**
If models are very similar, consider Single Table Inheritance instead.

---

## Summary

The three polymorphic associations provide:

- ✅ **Comments** for user feedback on products and orders
- ✅ **Addresses** for flexible location storage
- ✅ **Attachments** for file management across models

All implementations include:
- ✅ Comprehensive validations
- ✅ Useful scopes and methods
- ✅ Full test coverage (47 specs)
- ✅ Factory support
- ✅ Proper database indexes
- ✅ RuboCop compliant

**Total Test Count**: 200 examples, 0 failures ✨

---

## Migration Timeline

| Date | Action | Details |
|------|--------|---------|
| 2026-03-04 | Created Comments | Polymorphic for Product/Order |
| 2026-03-04 | Created Addresses | Polymorphic for User/Order |
| 2026-03-04 | Created Attachments | Polymorphic for Product/User/Order |
| 2026-03-04 | Added Tests | 47 comprehensive specs |
| 2026-03-04 | All Tests Passing | 200 examples, 0 failures |
