class ReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :comment, :created_at, :updated_at

  belongs_to :user
  belongs_to :product

  attribute :user_name do |review|
    review.user.email.split("@").first if review.user
  end
end
