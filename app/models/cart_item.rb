class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :user_id }

  before_validation :set_price, on: :create

  def subtotal
    quantity * price
  end

  private

  def set_price
    self.price = product.price if product.present? && price.nil?
  end
end
