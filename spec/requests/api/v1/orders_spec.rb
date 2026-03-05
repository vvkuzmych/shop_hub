require "rails_helper"

RSpec.describe "Api::V1::Orders", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }
  let(:product1) { create(:product, price: 29.99, stock: 10) }
  let(:product2) { create(:product, price: 19.99, stock: 5) }

  describe "GET /api/v1/orders" do
    let!(:user_orders) { create_list(:order, 3, user: user) }
    let!(:other_orders) { create_list(:order, 2) }

    it "returns only current user's orders" do
      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
    end

    it "orders are sorted by most recent first" do
      get "/api/v1/orders", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      order_ids = json["data"].map { |o| o["id"].to_i }
      expect(order_ids).to eq(user_orders.map(&:id).sort.reverse)
    end
  end

  describe "GET /api/v1/orders/:id" do
    let(:order) { create(:order, user: user) }

    it "returns order details with items" do
      get "/api/v1/orders/#{order.id}", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"]["id"].to_i).to eq(order.id)
      expect(json["data"]["attributes"]["status"]).to be_present
    end

    it "prevents access to other user's orders" do
      other_order = create(:order)

      get "/api/v1/orders/#{other_order.id}", headers: headers

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/orders" do
    context "with valid items" do
      it "creates a new order from cart items" do
        order_params = {
          items: [
            { product_id: product1.id, quantity: 2 },
            { product_id: product2.id, quantity: 1 }
          ],
          delivery_method: "delivery",
          delivery_address: "123 Test St, Test City, TS 12345"
        }

        expect {
          post "/api/v1/orders", params: order_params, headers: headers
        }.to change(Order, :count).by(1)
         .and change(OrderItem, :count).by(2)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["data"]["attributes"]["total_amount"]).to eq(79.97)
      end

      it "decreases product stock" do
        order_params = {
          items: [
            { product_id: product1.id, quantity: 2 }
          ],
          delivery_method: "delivery",
          delivery_address: "123 Test St, Test City, TS 12345"
        }

        expect {
          post "/api/v1/orders", params: order_params, headers: headers
        }.to change { product1.reload.stock }.from(10).to(8)
      end
    end

    context "with invalid items" do
      it "returns error for out of stock product" do
        product = create(:product, stock: 1)

        post "/api/v1/orders", params: {
          items: [
            { product_id: product.id, quantity: 5 }
          ]
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "returns error when no items provided" do
        post "/api/v1/orders", params: { items: [] }, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /api/v1/orders/:id/cancel" do
    context "with pending order" do
      let(:order) { create(:order, user: user, status: :pending) }

      it "cancels the order" do
        patch "/api/v1/orders/#{order.id}/cancel", headers: headers

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq("cancelled")
      end
    end

    context "with processing order" do
      let(:order) { create(:order, user: user, status: :processing, payment_status: :payment_paid) }

      it "prevents cancellation" do
        patch "/api/v1/orders/#{order.id}/cancel", headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(order.reload.status).to eq("processing")
      end
    end

    context "with other user's order" do
      let(:order) { create(:order, status: :pending) }

      it "prevents access" do
        patch "/api/v1/orders/#{order.id}/cancel", headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "when not authenticated" do
    it "returns unauthorized for index" do
      get "/api/v1/orders"
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for create" do
      post "/api/v1/orders", params: { items: [] }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
