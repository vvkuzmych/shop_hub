require "swagger_helper"

RSpec.describe "Products API", type: :request do
  path "/api/v1/products" do
    get "List products with filtering and search" do
      tags "Products"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, description: "Search query (name or description)", required: false
      parameter name: :category_id, in: :query, type: :integer, description: "Filter by category", required: false
      parameter name: :min_price, in: :query, type: :number, description: "Minimum price", required: false
      parameter name: :max_price, in: :query, type: :number, description: "Maximum price", required: false
      parameter name: :in_stock, in: :query, type: :boolean, description: "Only in-stock products", required: false
      parameter name: :featured, in: :query, type: :boolean, description: "Only featured products", required: false
      parameter name: :page, in: :query, type: :integer, description: "Page number", required: false
      parameter name: :per_page, in: :query, type: :integer, description: "Items per page (default: 20)", required: false

      response "200", "products found" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: "product" },
                       attributes: { "$ref" => "#/components/schemas/Product" }
                     }
                   }
                 },
                 meta: {
                   type: :object,
                   properties: {
                     current_page: { type: :integer },
                     total_pages: { type: :integer },
                     total_count: { type: :integer },
                     per_page: { type: :integer }
                   }
                 }
               }

        let!(:category) { create(:category) }
        let!(:products) { create_list(:product, 3, category: category, active: true, stock: 10) }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["data"]).not_to be_empty
        end
      end
    end
  end

  path "/api/v1/products/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Product ID"

    get "Retrieve a product" do
      tags "Products"
      produces "application/json"

      response "200", "product found" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string, example: "product" },
                     attributes: { "$ref" => "#/components/schemas/Product" }
                   }
                 }
               }

        let!(:product) { create(:product) }
        let(:id) { product.id }
        run_test!
      end

      response "404", "product not found" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { "invalid" }
        run_test!
      end
    end
  end

  path "/api/v1/products/search" do
    get "Search products" do
      tags "Products"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, description: "Search keyword", required: false
      parameter name: :page, in: :query, type: :integer, description: "Page number", required: false

      response "200", "search results" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: { "$ref" => "#/components/schemas/Product" }
                     }
                   }
                 }
               }

        let!(:product) { create(:product, name: "Laptop", active: true) }
        let(:q) { "Laptop" }
        run_test!
      end
    end
  end

  path "/api/v1/products/featured" do
    get "Get featured products" do
      tags "Products"
      produces "application/json"

      parameter name: :limit, in: :query, type: :integer, description: "Maximum number of products", required: false

      response "200", "featured products" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string },
                       attributes: { "$ref" => "#/components/schemas/Product" }
                     }
                   }
                 }
               }

        let!(:product) { create(:product, featured: true, stock: 5, active: true) }
        run_test!
      end
    end
  end
end
