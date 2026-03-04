require "rails_helper"

RSpec.describe "Api::V1::Products", type: :request do
  let!(:electronics) { create(:category, name: "Electronics") }
  let!(:books) { create(:category, name: "Books") }
  let!(:laptop) { create(:product, name: "Laptop", price: 999.99, stock: 5, category: electronics, active: true, featured: true) }
  let!(:mouse) { create(:product, name: "Mouse", price: 29.99, stock: 10, category: electronics, active: true) }
  let!(:keyboard) { create(:product, name: "Keyboard", price: 79.99, stock: 0, category: electronics, active: true) }
  let!(:book) { create(:product, name: "Ruby Book", price: 39.99, stock: 20, category: books, active: true) }

  describe "GET /api/v1/products" do
    it "returns all active products" do
      get "/api/v1/products"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(4)
    end

    it "filters by search query" do
      get "/api/v1/products", params: { q: "Laptop" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Laptop")
    end

    it "filters by category" do
      get "/api/v1/products", params: { category_id: electronics.id }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
    end

    it "filters by price range" do
      get "/api/v1/products", params: { min_price: 50, max_price: 100 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Keyboard")
    end

    it "filters by in_stock" do
      get "/api/v1/products", params: { in_stock: "true" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
      json["data"].each do |product|
        expect(product["attributes"]["stock"]).to be > 0
      end
    end

    it "filters by featured" do
      get "/api/v1/products", params: { featured: "true" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Laptop")
    end

    it "combines multiple filters" do
      get "/api/v1/products", params: {
        category_id: electronics.id,
        in_stock: "true",
        max_price: 100
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Mouse")
    end
  end

  describe "GET /api/v1/products/search" do
    it "searches products by name" do
      get "/api/v1/products/search", params: { q: "Book" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Ruby Book")
    end
  end

  describe "GET /api/v1/products/featured" do
    it "returns only featured products" do
      get "/api/v1/products/featured"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["name"]).to eq("Laptop")
    end

    it "respects limit parameter" do
      create_list(:product, 15, featured: true, stock: 5)

      get "/api/v1/products/featured", params: { limit: 5 }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(5)
    end
  end
end
