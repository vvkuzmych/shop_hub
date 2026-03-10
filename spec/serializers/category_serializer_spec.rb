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

RSpec.describe CategorySerializer do
  describe "serialization" do
    let!(:parent_category) { create(:category, name: "Electronics", description: "Electronic devices") }
    let!(:child1) { create(:category, name: "Phones", description: "Mobile phones", parent: parent_category) }
    let!(:child2) { create(:category, name: "Laptops", description: "Laptop computers", parent: parent_category) }

    context "with single category" do
      it "serializes category with all attributes" do
        serializer = CategorySerializer.new(parent_category)
        result = serializer.serializable_hash

        expect(result[:data]).to be_present
        expect(result[:data][:id]).to eq(parent_category.id.to_s)
        expect(result[:data][:type]).to eq(:category)
        expect(result[:data][:attributes][:name]).to eq("Electronics")
        expect(result[:data][:attributes][:description]).to eq("Electronic devices")
        expect(result[:data][:attributes][:parent_id]).to be_nil
      end

      it "includes subcategories" do
        parent_category.reload
        serializer = CategorySerializer.new(parent_category)
        result = serializer.serializable_hash

        subcategories = result[:data][:attributes][:subcategories]
        expect(subcategories).to be_an(Array)
        expect(subcategories.size).to eq(2)
        expect(subcategories.map { |s| s[:name] }).to match_array([ "Phones", "Laptops" ])
      end
    end

    context "with multiple categories" do
      it "serializes collection" do
        categories = Category.root_categories.includes(:children)
        serializer = CategorySerializer.new(categories)
        result = serializer.serializable_hash

        expect(result[:data]).to be_an(Array)
        expect(result[:data].size).to eq(1)
        expect(result[:data].first[:attributes][:subcategories].size).to eq(2)
      end
    end
  end
end
