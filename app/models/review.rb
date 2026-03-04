class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "can only review a product once" }

  # Counter cache
  after_create :update_product_rating
  after_destroy :update_product_rating

  private

  def update_product_rating
    product.update(average_rating: product.reviews.average(:rating))
  end
end
