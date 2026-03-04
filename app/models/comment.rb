# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  commentable_type :string           not null
#  content          :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  commentable_id   :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_comments_on_commentable                          (commentable_type,commentable_id)
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_user_id                              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Comment < ApplicationRecord
  # Polymorphic association - can belong to Product, Order, etc.
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  # Validations
  validates :content, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :commentable_type, inclusion: { in: %w[Product Order] }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :for_product, -> { where(commentable_type: "Product") }
  scope :for_order, -> { where(commentable_type: "Order") }

  # Methods
  def author_name
    user.full_name
  end
end
