class ReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :comment, :created_at

  belongs_to :user
  belongs_to :product
end
