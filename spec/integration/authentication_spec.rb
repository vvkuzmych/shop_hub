require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  path "/api/v1/signup" do
    post "Register a new user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: "user@example.com" },
              password: { type: :string, example: "password123" },
              password_confirmation: { type: :string, example: "password123" },
              first_name: { type: :string, example: "John" },
              last_name: { type: :string, example: "Doe" }
            },
            required: [ "email", "password", "password_confirmation" ]
          }
        }
      }

      response "200", "user created" do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: "Signed up successfully." }
                   }
                 },
                 data: { "$ref" => "#/components/schemas/User" }
               }

        let(:user) { { user: { email: "test@example.com", password: "password123", password_confirmation: "password123" } } }
        run_test!
      end

      response "422", "invalid request" do
        schema "$ref" => "#/components/schemas/ValidationError"
        let(:user) { { user: { email: "invalid", password: "123" } } }
        run_test!
      end
    end
  end

  path "/api/v1/login" do
    post "Login user" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: "user@example.com" },
              password: { type: :string, example: "password123" }
            },
            required: [ "email", "password" ]
          }
        }
      }

      response "200", "logged in successfully" do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: "Logged in successfully." }
                   }
                 },
                 data: { "$ref" => "#/components/schemas/User" }
               },
               required: [ "status", "data" ]

        header "Authorization", type: :string, description: "JWT token in format: Bearer <token>"

        let!(:user) { create(:user, email: "test@example.com", password: "password123") }
        let(:credentials) { { user: { email: "test@example.com", password: "password123" } } }
        run_test!
      end

      response "401", "invalid credentials" do
        schema "$ref" => "#/components/schemas/Error"
        let(:credentials) { { user: { email: "wrong@example.com", password: "wrong" } } }
        run_test!
      end
    end
  end

  path "/api/v1/logout" do
    delete "Logout user" do
      tags "Authentication"
      produces "application/json"
      security [ Bearer: [] ]

      response "200", "logged out successfully" do
        schema type: :object,
               properties: {
                 status: { type: :integer, example: 200 },
                 message: { type: :string, example: "Logged out successfully." }
               }

        let!(:user) { create(:user) }
        let(:Authorization) { "Bearer #{generate_jwt_token(user)}" }
        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/Error"
        let(:Authorization) { "Bearer invalid_token" }
        run_test!
      end
    end
  end

  def generate_jwt_token(user)
    jwt_payload = { sub: user.id, scp: "user", jti: SecureRandom.uuid }
    JWT.encode(jwt_payload, Rails.application.credentials.devise_jwt_secret_key!)
  end
end
