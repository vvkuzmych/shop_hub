class Category < ApplicationRecord
  # Self-referential association (вкладені категорії)
  belongs_to :parent, class_name: "Category", optional: true
  has_many :children, class_name: "Category", foreign_key: "parent_id", dependent: :destroy
  has_many :products, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { scope: :parent_id }

  # Scopes
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(position: :asc) }

  # Methods
  def subcategories
    children
  end

  def all_products
    # Рекурсивно отримати всі продукти з підкатегорій
    Product.where(category_id: descendant_ids + [ id ])
  end

  def descendant_ids
    children.flat_map { |child| [ child.id ] + child.descendant_ids }
  end
end
