require "rails_helper"

RSpec.describe "Api::V1::Admin::Categories", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:customer) { create(:user, role: :customer) }
  let(:admin_headers) { auth_headers(admin) }
  let(:customer_headers) { auth_headers(customer) }

  describe "GET /api/v1/admin/categories" do
    let!(:categories) { create_list(:category, 3) }

    context "as admin" do
      it "returns all categories" do
        get "/api/v1/admin/categories", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end
    end

    context "as customer" do
      it "denies access" do
        get "/api/v1/admin/categories", headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /api/v1/admin/categories" do
    context "as admin" do
      it "creates a new category" do
        expect {
          post "/api/v1/admin/categories", params: {
            category: {
              name: "New Category",
              description: "Description"
            }
          }, headers: admin_headers, as: :json
        }.to change(Category, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end
  end

  describe "PATCH /api/v1/admin/categories/:id" do
    let(:category) { create(:category) }

    context "as admin" do
      it "updates the category" do
        patch "/api/v1/admin/categories/#{category.id}", params: {
          category: { name: "Updated Name" }
        }, headers: admin_headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(category.reload.name).to eq("Updated Name")
      end
    end
  end

  describe "DELETE /api/v1/admin/categories/:id" do
    let!(:category) { create(:category) }

    context "as admin" do
      it "deletes the category" do
        expect {
          delete "/api/v1/admin/categories/#{category.id}", headers: admin_headers
        }.to change(Category, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
