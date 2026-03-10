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

RSpec.describe ReviewSerializer do
  let(:user) { create(:user, email: "john@example.com", first_name: "John", last_name: "Doe") }
  let(:product) { create(:product) }

  describe ".format" do
    let(:review) do
      create(:review,
        product: product,
        user: user,
        rating: 5,
        comment: "Excellent product!")
    end

    it "formats a single review correctly" do
      result = described_class.format(review)

      expect(result).to include(
        id: review.id,
        rating: 5,
        comment: "Excellent product!"
      )
      expect(result[:user]).to include(
        id: user.id,
        full_name: "John Doe"
      )
      expect(result[:created_at]).to be_present
    end
  end

  describe ".format_collection" do
    let!(:review1) do
      create(:review,
        product: product,
        user: user,
        rating: 5,
        comment: "Great product, highly recommended!")
    end
    let!(:review2) do
      create(:review,
        product: product,
        rating: 4,
        comment: "Good quality and fast delivery!")
    end

    it "formats multiple reviews" do
      reviews = Review.where(product: product).includes(:user)
      result = described_class.format_collection(reviews)

      expect(result).to be_an(Array)
      expect(result.size).to eq(2)
      expect(result.first[:rating]).to be_in([ 4, 5 ])
      expect(result.first[:user][:full_name]).to be_present
    end
  end

  describe "JSONAPI serialization" do
    let(:review) do
      create(:review,
        product: product,
        user: user,
        rating: 5,
        comment: "Excellent!")
    end

    it "includes JSONAPI formatted data" do
      result = described_class.new(review).serializable_hash

      expect(result).to have_key(:data)
      expect(result[:data][:attributes]).to include(
        rating: 5,
        comment: "Excellent!"
      )
    end
  end
end
