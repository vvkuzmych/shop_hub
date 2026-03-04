require "swagger_helper"

RSpec.describe "Orders API", type: :request do
  path "/api/v1/orders" do
    get "List user's orders" do
      tags "Orders"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "orders retrieved" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string },
                       type: { type: :string, example: "order" },
                       attributes: { "$ref" => "#/components/schemas/Order" }
                     }
                   }
                 }
               }

        let!(:user) { create(:user) }
        let!(:orders) { create_list(:order, 2, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        run_test!
      end
    end

    post "Create a new order" do
      tags "Orders"
      consumes "application/json"
      produces "application/json"
      security [ Bearer: [] ]

      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer, example: 1 },
                quantity: { type: :integer, example: 2 }
              },
              required: [ "product_id", "quantity" ]
            }
          }
        },
        required: [ "items" ]
      }

      response "201", "order created" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string, example: "order" },
                     attributes: { "$ref" => "#/components/schemas/Order" }
                   }
                 }
               }

        let!(:user) { create(:user) }
        let!(:product) { create(:product, stock: 10, price: 29.99) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:order) { { items: [ { product_id: product.id, quantity: 2 } ] } }
        run_test!
      end

      response "422", "invalid order" do
        schema "$ref" => "#/components/schemas/Error"
        let!(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:order) { { items: [] } }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:order) { { items: [] } }
        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Order ID"

    get "Retrieve an order" do
      tags "Orders"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "order found" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string, example: "order" },
                     attributes: { "$ref" => "#/components/schemas/Order" }
                   }
                 }
               }

        let!(:user) { create(:user) }
        let!(:order) { create(:order, user: user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:id) { order.id }
        run_test!
      end

      response "404", "order not found" do
        schema "$ref" => "#/components/schemas/Error"
        let!(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:id) { 999999 }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 1 }
        run_test!
      end
    end
  end

  path "/api/v1/orders/{id}/cancel" do
    parameter name: :id, in: :path, type: :integer, description: "Order ID"

    patch "Cancel a pending order" do
      tags "Orders"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "order cancelled" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     id: { type: :string },
                     type: { type: :string, example: "order" },
                     attributes: { "$ref" => "#/components/schemas/Order" }
                   }
                 }
               }

        let!(:user) { create(:user) }
        let!(:order) { create(:order, user: user, status: :pending) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:id) { order.id }
        run_test!
      end

      response "422", "cannot cancel order" do
        schema "$ref" => "#/components/schemas/Error"
        let!(:user) { create(:user) }
        let!(:order) { create(:order, user: user, status: :confirmed) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        let(:id) { order.id }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:id) { 1 }
        run_test!
      end
    end
  end

  def generate_jwt_token(user)
    jwt_payload = { sub: user.id, scp: "user", jti: SecureRandom.uuid }
    JWT.encode(jwt_payload, Rails.application.credentials.devise_jwt_secret_key!)
  end
end
