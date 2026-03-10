require "rails_helper"

RSpec.describe "Api::V1::Admin::Products", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:customer) { create(:user, role: :customer) }
  let(:admin_headers) { auth_headers(admin) }
  let(:customer_headers) { auth_headers(customer) }
  let(:category) { create(:category) }

  describe "GET /api/v1/admin/products" do
    let!(:products) { create_list(:product, 3) }

    context "as admin" do
      it "returns all products" do
        get "/api/v1/admin/products", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["data"].size).to eq(3)
      end
    end

    context "as customer" do
      it "denies access" do
        get "/api/v1/admin/products", headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/admin/products" do
    context "as admin" do
      it "creates a new product" do
        product_params = {
          product: {
            name: "New Product",
            description: "Description",
            price: 99.99,
            stock: 10,
            category_id: category.id
          }
        }

        expect {
          post "/api/v1/admin/products", params: product_params, headers: admin_headers, as: :json
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "as customer" do
      it "denies access" do
        post "/api/v1/admin/products", params: { product: { name: "Test" } }, headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/v1/admin/products/:id" do
    let(:product) { create(:product) }

    context "as admin" do
      it "updates the product" do
        patch "/api/v1/admin/products/#{product.id}", params: {
          product: { name: "Updated Name" }
        }, headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(product.reload.name).to eq("Updated Name")
      end
    end

    context "as customer" do
      it "denies access" do
        patch "/api/v1/admin/products/#{product.id}", params: {
          product: { name: "Hacked" }
        }, headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/v1/admin/products/:id" do
    let!(:product) { create(:product) }

    context "as admin" do
      it "deletes the product" do
        expect {
          delete "/api/v1/admin/products/#{product.id}", headers: admin_headers
        }.to change(Product, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
