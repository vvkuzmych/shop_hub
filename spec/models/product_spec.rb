require "rails_helper"

RSpec.describe Product, type: :model do
  # Association tests (shoulda-matchers)
  describe "associations" do
    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_many(:order_items) }
    it { is_expected.to have_many(:reviews) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than(0) }
    it { is_expected.to validate_uniqueness_of(:sku) }
  end

  # Scope tests
  describe "scopes" do
    let!(:active_product) { create(:product, active: true) }
    let!(:inactive_product) { create(:product, active: false) }

    it "returns only active products" do
      expect(Product.active).to include(active_product)
      expect(Product.active).not_to include(inactive_product)
    end

    it "returns only in-stock products" do
      in_stock = create(:product, stock: 10)
      out_of_stock = create(:product, :out_of_stock)

      expect(Product.in_stock).to include(in_stock)
      expect(Product.in_stock).not_to include(out_of_stock)
    end
  end

  # Method tests
  describe "#in_stock?" do
    it "returns true when stock > 0" do
      product = create(:product, stock: 5)
      expect(product.in_stock?).to be true
    end

    it "returns false when stock = 0" do
      product = create(:product, :out_of_stock)
      expect(product.in_stock?).to be false
    end
  end

  describe "#average_rating" do
    let(:product) { create(:product) }

    it "calculates average rating from reviews" do
      create(:review, product: product, rating: 4)
      create(:review, product: product, rating: 5)

      expect(product.average_rating).to eq(4.5)
    end
  end
end
