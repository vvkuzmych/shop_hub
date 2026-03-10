# == Schema Information
#
# Table name: reviews
#
#  id         :bigint           not null, primary key
#  comment    :text
#  rating     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  product_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_reviews_on_product_id  (product_id)
#  index_reviews_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class ReviewSerializer
  include JSONAPI::Serializer

  attributes :rating, :comment, :created_at, :updated_at

  belongs_to :user
  belongs_to :product

  attribute :user_name do |review|
    review.user.email.split("@").first if review.user
  end

  # Simple format methods for plain JSON responses
  def self.format(review)
    {
      id: review.id,
      rating: review.rating,
      comment: review.comment,
      user: {
        id: review.user.id,
        full_name: review.user.full_name
      },
      created_at: review.created_at
    }
  end

  def self.format_collection(reviews)
    reviews.map { |review| format(review) }
  end
end
