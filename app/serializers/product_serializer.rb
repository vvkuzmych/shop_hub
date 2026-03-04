class ProductSerializer
  include JSONAPI::Serializer

  attributes :name, :description, :price, :stock, :sku, :active

  belongs_to :category

  attribute :in_stock do |product|
    product.in_stock?
  end
end
