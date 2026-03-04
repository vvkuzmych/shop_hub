class Product < ApplicationRecord
  # Associations
  belongs_to :category
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :reviews, dependent: :destroy
  has_many_attached :images  # ActiveStorage для зображень

  # Validations
  validates :name, :price, :stock, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :sku, uniqueness: true, allow_nil: true

  # Scopes (ActiveRecord query interface)
  scope :active, -> { where(active: true) }
  scope :in_stock, -> { where("stock > ?", 0) }
  scope :available, -> { where(active: true).where("stock > ?", 0) }
  scope :by_category, ->(category_id) { where(category_id: category_id) }
  scope :search, ->(query) { where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%") }

  # Callbacks (Ruby blocks)
  before_save :generate_sku, if: -> { sku.blank? }

  # Methods
  def in_stock?
    stock > 0
  end

  def average_rating
    reviews.average(:rating).to_f.round(2)
  end

  private

  def generate_sku
    self.sku = "PROD-#{SecureRandom.hex(4).upcase}"
  end
end
