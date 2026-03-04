# == Schema Information
#
# Table name: categories
#
#  id          :bigint           not null, primary key
#  description :text
#  name        :string
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  parent_id   :integer
#
# Indexes
#
#  index_categories_on_name  (name) UNIQUE
#

require "rails_helper"

RSpec.describe Category, type: :model do
  # Association tests
  describe "associations" do
    it { is_expected.to belong_to(:parent).class_name("Category").optional }
    it { is_expected.to have_many(:children).class_name("Category").with_foreign_key("parent_id").dependent(:destroy) }
    it { is_expected.to have_many(:products).dependent(:destroy) }
  end

  # Validation tests
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates uniqueness of name scoped to parent_id" do
      parent = create(:category, name: "Parent")
      create(:category, name: "Electronics", parent: parent)

      duplicate = build(:category, name: "Electronics", parent: parent)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "allows same name in different parent categories" do
      parent1 = create(:category, name: "Parent 1")
      parent2 = create(:category, name: "Parent 2")

      category1 = create(:category, name: "Phones", parent: parent1)
      category2 = build(:category, name: "Phones", parent: parent2)

      expect(category2).to be_valid
    end
  end

  # Scope tests
  describe "scopes" do
    describe ".root_categories" do
      it "returns only categories without parent" do
        root1 = create(:category, parent: nil)
        root2 = create(:category, parent: nil)
        child = create(:category, parent: root1)

        expect(Category.root_categories).to include(root1, root2)
        expect(Category.root_categories).not_to include(child)
      end
    end

    describe ".ordered" do
      it "returns categories ordered by position" do
        cat3 = create(:category, position: 3)
        cat1 = create(:category, position: 1)
        cat2 = create(:category, position: 2)

        expect(Category.ordered).to eq([ cat1, cat2, cat3 ])
      end
    end
  end

  # Method tests
  describe "#subcategories" do
    it "returns children categories" do
      parent = create(:category)
      child1 = create(:category, parent: parent)
      child2 = create(:category, parent: parent)

      expect(parent.subcategories).to match_array([ child1, child2 ])
    end
  end

  describe "#all_products" do
    it "returns products from category and all subcategories" do
      parent = create(:category)
      child = create(:category, parent: parent)
      grandchild = create(:category, parent: child)

      product1 = create(:product, category: parent)
      product2 = create(:product, category: child)
      product3 = create(:product, category: grandchild)
      other_product = create(:product)

      expect(parent.all_products).to match_array([ product1, product2, product3 ])
      expect(parent.all_products).not_to include(other_product)
    end
  end
end
