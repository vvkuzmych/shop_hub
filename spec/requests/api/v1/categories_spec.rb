require "rails_helper"

RSpec.describe "Api::V1::Categories", type: :request do
  let!(:parent_category) { create(:category, name: "Electronics", parent: nil) }
  let!(:child_category) { create(:category, name: "Phones", parent: parent_category) }
  let!(:product1) { create(:product, category: child_category) }
  let!(:product2) { create(:product, category: child_category) }

  describe "GET /api/v1/categories" do
    it "returns all root categories with subcategories" do
      get "/api/v1/categories"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(1)
      expect(json.first["name"]).to eq("Electronics")
      expect(json.first["subcategories"].size).to eq(1)
      expect(json.first["subcategories"].first["name"]).to eq("Phones")
    end
  end

  describe "GET /api/v1/categories/:id" do
    it "returns category with subcategories" do
      get "/api/v1/categories/#{parent_category.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["name"]).to eq("Electronics")
      expect(json["subcategories"].size).to eq(1)
    end
  end

  describe "GET /api/v1/categories/:id/products" do
    it "returns all products in category and subcategories" do
      get "/api/v1/categories/#{parent_category.id}/products"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(2)
    end
  end
end
