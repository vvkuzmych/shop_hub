# Model Annotations with annot8

## What It Does

Automatically adds schema documentation comments to your Rails models, specs, and factories.

## Quick Usage

### Auto-Update (Already Configured)
Annotations update automatically when you run:
```bash
rails db:migrate
rails db:rollback
```

### Manual Update
```bash
bundle exec rake annotate_models
```

## Example Output

Before:
```ruby
class Product < ApplicationRecord
  belongs_to :category
end
```

After:
```ruby
# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  name        :string
#  price       :decimal(, )
#  stock       :integer
#  category_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_products_on_sku  (sku) UNIQUE
#
class Product < ApplicationRecord
  belongs_to :category
end
```

## What Gets Annotated

- ✅ Models (`app/models/*.rb`)
- ✅ Model specs (`spec/models/*.rb`)
- ✅ Factories (`spec/factories/*.rb`)
- ✅ Serializers (`app/serializers/*.rb`)

## Common Commands

```bash
# Annotate all models
bundle exec rake annotate_models

# Remove all annotations
bundle exec rake annotate_models:remove

# Show options
bundle exec rake -T annotate
```

## Configuration

Edit `lib/tasks/auto_annotate_models.rake` to customize:
- Which files to annotate
- Position of annotations (top/bottom)
- What information to include

## Benefits

- 📖 Instant schema reference in your code
- 🚀 Faster development (no need to check schema.rb)
- 👥 Better team collaboration
- 📝 Self-documenting code

## Gem Info

Using: **annot8** (Rails 8+ compatible fork of annotate)
- GitHub: https://github.com/drwl/annot8
- RubyGems: https://rubygems.org/gems/annot8
