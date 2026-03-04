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
