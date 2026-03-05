require "rails_helper"

RSpec.describe "Api::V1::Carts", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product, price: 29.99) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/cart/items" do
    let!(:cart_item1) { create(:cart_item, user: user, product: product, quantity: 2, price: 29.99) }
    let!(:cart_item2) { create(:cart_item, user: user, quantity: 1, price: 19.99) }

    it "returns cart items for current user" do
      get "/api/v1/cart/items", headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["cart_items"].size).to eq(2)
      expect(json["total"]).to eq(79.97)
    end
  end

  describe "POST /api/v1/cart/add_item" do
    context "with valid parameters" do
      it "adds new item to cart" do
        expect {
          post "/api/v1/cart/add_item", params: {
            product_id: product.id,
            quantity: 2
          }, headers: headers
        }.to change(CartItem, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Product added to cart")
        expect(json["cart_item"]["quantity"]).to eq(2)
      end

      it "increases quantity for existing cart item" do
        create(:cart_item, user: user, product: product, quantity: 1)

        expect {
          post "/api/v1/cart/add_item", params: {
            product_id: product.id,
            quantity: 2
          }, headers: headers
        }.not_to change(CartItem, :count)

        expect(response).to have_http_status(:created)
        cart_item = user.cart_items.find_by(product: product)
        expect(cart_item.quantity).to eq(3)
      end
    end

    context "with invalid parameters" do
      it "returns errors for invalid quantity" do
        post "/api/v1/cart/add_item", params: {
          product_id: product.id,
          quantity: 0
        }, headers: headers

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /api/v1/cart/remove_item" do
    let!(:cart_item) { create(:cart_item, user: user, product: product) }

    it "removes item from cart" do
      expect {
        delete "/api/v1/cart/remove_item", params: {
          product_id: product.id
        }, headers: headers
      }.to change(CartItem, :count).by(-1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Item removed from cart")
    end
  end

  describe "PATCH /api/v1/cart/update_quantity" do
    let!(:cart_item) { create(:cart_item, user: user, product: product, quantity: 2) }

    context "with valid quantity" do
      it "updates cart item quantity" do
        patch "/api/v1/cart/update_quantity", params: {
          product_id: product.id,
          quantity: 5
        }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(cart_item.reload.quantity).to eq(5)
      end
    end

    context "with zero or negative quantity" do
      it "removes the item from cart" do
        expect {
          patch "/api/v1/cart/update_quantity", params: {
            product_id: product.id,
            quantity: 0
          }, headers: headers
        }.to change(CartItem, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Quantity updated")
      end
    end
  end

  describe "DELETE /api/v1/cart/clear" do
    let!(:cart_items) { create_list(:cart_item, 3, user: user) }

    it "clears all cart items" do
      expect {
        delete "/api/v1/cart/clear", headers: headers
      }.to change { user.cart_items.count }.from(3).to(0)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Cart cleared")
    end
  end
end
