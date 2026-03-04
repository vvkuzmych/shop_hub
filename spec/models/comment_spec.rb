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
require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:commentable) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_least(10).is_at_most(2000) }
    it { is_expected.to validate_inclusion_of(:commentable_type).in_array(%w[Product Order]) }
  end

  describe "scopes" do
    let!(:product) { create(:product) }
    let!(:order) { create(:order) }
    let!(:user) { create(:user) }
    let!(:product_comment) { create(:comment, commentable: product, user: user) }
    let!(:order_comment) { create(:comment, commentable: order, user: user) }

    describe ".recent" do
      it "returns comments ordered by most recent first" do
        expect(Comment.recent.first).to eq(order_comment)
      end
    end

    describe ".for_product" do
      it "returns only product comments" do
        expect(Comment.for_product).to contain_exactly(product_comment)
      end
    end

    describe ".for_order" do
      it "returns only order comments" do
        expect(Comment.for_order).to contain_exactly(order_comment)
      end
    end
  end

  describe "polymorphic behavior" do
    let(:user) { create(:user) }
    let(:product) { create(:product) }
    let(:order) { create(:order, user: user) }

    it "can be associated with a product" do
      comment = create(:comment, commentable: product, user: user)
      expect(comment.commentable).to eq(product)
      expect(comment.commentable_type).to eq("Product")
    end

    it "can be associated with an order" do
      comment = create(:comment, commentable: order, user: user)
      expect(comment.commentable).to eq(order)
      expect(comment.commentable_type).to eq("Order")
    end
  end

  describe "#author_name" do
    let(:user) { create(:user, first_name: "John", last_name: "Doe") }
    let(:comment) { create(:comment, user: user) }

    it "returns the user's full name" do
      expect(comment.author_name).to eq("John Doe")
    end
  end
end
