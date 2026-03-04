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

  attributes :name, :description, :price, :stock, :sku, :active, :average_rating

  belongs_to :category
  has_many :reviews

  # Custom attributes (Ruby блоки)
  attribute :in_stock do |product|
    product.in_stock?
  end

  attribute :image_urls do |product|
    product.images.map { |img| Rails.application.routes.url_helpers.url_for(img) }
  end

  # Conditional attributes
  attribute :admin_info, if: Proc.new { |record, params|
    params && params[:current_user]&.admin?
  } do |product|
    {
      cost: product.cost,
      margin: product.margin
    }
  end
end
