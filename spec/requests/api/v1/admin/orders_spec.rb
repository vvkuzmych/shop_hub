require "rails_helper"

RSpec.describe "Api::V1::Admin::Orders", type: :request do
  let(:admin) { create(:user, role: :admin) }
  let(:customer) { create(:user, role: :customer) }
  let(:admin_headers) { auth_headers(admin) }
  let(:customer_headers) { auth_headers(customer) }

  describe "GET /api/v1/admin/orders" do
    let!(:orders) { create_list(:order, 3) }

    context "as admin" do
      it "returns all orders" do
        get "/api/v1/admin/orders", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.size).to eq(3)
      end
    end

    context "as customer" do
      it "denies access" do
        get "/api/v1/admin/orders", headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/admin/orders/:id" do
    let(:order) { create(:order) }

    context "as admin" do
      it "returns order details" do
        get "/api/v1/admin/orders/#{order.id}", headers: admin_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(order.id)
        expect(json["user"]).to be_present
        expect(json["items"]).to be_present
      end
    end
  end

  describe "PATCH /api/v1/admin/orders/:id" do
    let(:order) { create(:order, status: :pending) }

    context "as admin" do
      it "updates order status" do
        patch "/api/v1/admin/orders/#{order.id}", params: {
          order: { status: :processing }
        }, headers: admin_headers

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq("processing")
      end
    end

    context "as customer" do
      it "denies access" do
        patch "/api/v1/admin/orders/#{order.id}", params: {
          order: { status: :cancelled }
        }, headers: customer_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
