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

require "rails_helper"

RSpec.describe Review, type: :model do
  # Association tests
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:product) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_inclusion_of(:rating).in_range(1..5) }

    it "validates comment minimum length" do
      review = build(:review, comment: "Short")
      expect(review).not_to be_valid
      expect(review.errors[:comment]).to include("is too short (minimum is 10 characters)")
    end

    it "validates comment maximum length" do
      review = build(:review, comment: "a" * 1001)
      expect(review).not_to be_valid
      expect(review.errors[:comment]).to include("is too long (maximum is 1000 characters)")
    end

    it "validates user can only review a product once" do
      user = create(:user)
      product = create(:product)
      create(:review, user: user, product: product)

      duplicate_review = build(:review, user: user, product: product)
      expect(duplicate_review).not_to be_valid
      expect(duplicate_review.errors[:user_id]).to include("can only review a product once")
    end

    it "allows same user to review different products" do
      user = create(:user)
      product1 = create(:product)
      product2 = create(:product)

      create(:review, user: user, product: product1)
      review2 = build(:review, user: user, product: product2)

      expect(review2).to be_valid
    end
  end

  # Rating tests
  describe "rating values" do
    it "accepts ratings from 1 to 5" do
      (1..5).each do |rating|
        review = build(:review, rating: rating)
        expect(review).to be_valid
      end
    end

    it "rejects ratings outside 1-5 range" do
      [ 0, 6, -1, 10 ].each do |invalid_rating|
        review = build(:review, rating: invalid_rating)
        expect(review).not_to be_valid
      end
    end
  end
end
