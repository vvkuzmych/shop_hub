require "swagger_helper"

RSpec.describe "Shopping Cart API", type: :request do
  path "/api/v1/cart/items" do
    get "View cart items" do
      tags "Shopping Cart"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "cart items retrieved" do
        schema type: :object,
               properties: {
                 items: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       product: { "$ref" => "#/components/schemas/Product" },
                       quantity: { type: :integer },
                       price: { type: :number },
                       subtotal: { type: :number }
                     }
                   }
                 },
                 total: { type: :number, example: 149.99 }
               }

        let!(:user) { create(:user) }
        let!(:product) { create(:product, price: 49.99, stock: 10) }
        let!(:cart_item) { create(:cart_item, user: user, product: product, quantity: 2) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        run_test!
      end
    end
  end

  path "/api/v1/cart/add_item" do
    post "Add item to cart" do
      tags "Shopping Cart"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer, example: 1 },
          quantity: { type: :integer, example: 2, minimum: 1 }
        },
        required: [ "product_id", "quantity" ]
      }

      response "200", "item added to cart" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Item added to cart" },
                 cart_item: { "$ref" => "#/components/schemas/CartItem" }
               }

        let!(:user) { create(:user) }
        let!(:product) { create(:product, stock: 10) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:item) { { product_id: product.id, quantity: 2 } }
        run_test!
      end

      response "422", "invalid item" do
        schema "$ref" => "#/components/schemas/Error"
        let!(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:item) { { product_id: 999999, quantity: 1 } }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:item) { { product_id: 1, quantity: 1 } }
        run_test!
      end
    end
  end

  path "/api/v1/cart/update_quantity" do
    patch "Update cart item quantity" do
      tags "Shopping Cart"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer, example: 1 },
          quantity: { type: :integer, example: 3, minimum: 1 }
        },
        required: [ "product_id", "quantity" ]
      }

      response "200", "quantity updated" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Quantity updated" },
                 cart_item: { "$ref" => "#/components/schemas/CartItem" }
               }

        let!(:user) { create(:user) }
        let!(:product) { create(:product, stock: 10) }
        let!(:cart_item) { create(:cart_item, user: user, product: product, quantity: 1) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:item) { { product_id: product.id, quantity: 3 } }
        run_test!
      end

      response "404", "item not in cart" do
        schema "$ref" => "#/components/schemas/Error"
        let!(:user) { create(:user) }
        let!(:product) { create(:product) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:item) { { product_id: product.id, quantity: 1 } }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:item) { { product_id: 1, quantity: 1 } }
        run_test!
      end
    end
  end

  path "/api/v1/cart/remove_item" do
    delete "Remove item from cart" do
      tags "Shopping Cart"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :item, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer, example: 1 }
        },
        required: [ "product_id" ]
      }

      response "200", "item removed" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Item removed from cart" }
               }

        let!(:user) { create(:user) }
        let!(:product) { create(:product) }
        let!(:cart_item) { create(:cart_item, user: user, product: product) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:item) { { product_id: product.id } }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:item) { { product_id: 1 } }
        run_test!
      end
    end
  end

  path "/api/v1/cart/clear" do
    delete "Clear entire cart" do
      tags "Shopping Cart"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "cart cleared" do
        schema type: :object,
               properties: {
                 message: { type: :string, example: "Cart cleared" }
               }

        let!(:user) { create(:user) }
        let!(:cart_items) { create_list(:cart_item, 3, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        run_test!
      end
    end
  end

  def generate_jwt_token(user)
    jwt_payload = { sub: user.id, scp: "user", jti: SecureRandom.uuid }
    JWT.encode(jwt_payload, Rails.application.credentials.devise_jwt_secret_key!)
  end
end
