# == Schema Information
#
# Table name: products
#
#  id          :bigint           not null, primary key
#  active      :boolean
#  description :text
#  featured    :boolean          default(FALSE), not null
#  name        :string
#  price       :decimal(, )
#  sku         :string
#  stock       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category_id :integer
#
# Indexes
#
#  index_products_on_featured  (featured)
#  index_products_on_sku       (sku) UNIQUE
#
class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :stock, :sku, :active, :created_at, :updated_at

  belongs_to :category
  has_many :reviews

  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :average_rating do |product|
    # Use loaded reviews to avoid N+1 query
    if product.reviews.loaded?
      if product.reviews.empty?
        0.0
      else
        (product.reviews.sum(&:rating).to_f / product.reviews.size).round(2)
      end
    else
      product.average_rating
    end
  end

  attribute :reviews_count do |product|
    product.reviews.loaded? ? product.reviews.size : product.reviews.count
  end

  attribute :image_urls do |product|
    if product.images.attached?
      product.images.map do |image|
        Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
      end
    else
      []
    end
  end
end
