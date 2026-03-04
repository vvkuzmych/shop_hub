class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "can only review a product once" }
end
