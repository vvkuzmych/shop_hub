class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Callback: зберегти поточну ціну продукту
  before_validation :set_price, on: :create

  private

  def set_price
    self.price = product.price if price.nil?
  end
end
