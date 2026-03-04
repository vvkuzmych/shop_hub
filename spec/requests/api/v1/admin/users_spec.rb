require "rails_helper"

RSpec.describe "Api::V1::Admin::Users", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:customer) { create(:user, role: :customer) }
  let(:admin_headers) { auth_headers(admin) }
  let(:customer_headers) { auth_headers(customer) }

  describe "GET /api/v1/admin/users" do
    let!(:users) { create_list(:user, 3) }

    context "as admin" do
      it "returns all users" do
        get "/api/v1/admin/users", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to be >= 3
      end
    end

    context "as customer" do
      it "denies access" do
        get "/api/v1/admin/users", headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/admin/users/:id" do
    let(:user) { create(:user) }

    context "as admin" do
      it "returns user details" do
        get "/api/v1/admin/users/#{user.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(user.id)
        expect(json["email"]).to eq(user.email)
        expect(json["full_name"]).to be_present
      end
    end

    context "as customer" do
      it "denies access" do
        get "/api/v1/admin/users/#{user.id}", headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
