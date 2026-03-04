require "rails_helper"

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured, as per the README file, to load Swagger from
  # the same folder
  config.openapi_root = Rails.root.join("swagger").to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "ShopHub API",
        version: "v1",
        description: "E-commerce REST API with JWT authentication, product management, shopping cart, orders, and admin panel.",
        contact: {
          name: "ShopHub API Support",
          email: "api@shophub.example.com"
        },
        license: {
          name: "MIT",
          url: "https://opensource.org/licenses/MIT"
        }
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development server"
        },
        {
          url: "https://api.shophub.example.com",
          description: "Production server"
        }
      ],
      components: {
        securitySchemes: {
          Bearer: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT",
            description: "JWT token obtained from login endpoint"
          }
        },
        schemas: {
          User: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string },
              first_name: { type: :string },
              last_name: { type: :string },
              role: { type: :string, enum: [ "customer", "admin" ] },
              created_at: { type: :string, format: "date-time" }
            },
            required: [ "email", "role" ]
          },
          Product: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string },
              price: { type: :number, format: :float },
              stock: { type: :integer },
              sku: { type: :string },
              active: { type: :boolean },
              featured: { type: :boolean },
              category_id: { type: :integer },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: [ "name", "price", "category_id" ]
          },
          Category: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string },
              parent_id: { type: :integer, nullable: true },
              created_at: { type: :string, format: "date-time" }
            },
            required: [ "name" ]
          },
          Order: {
            type: :object,
            properties: {
              id: { type: :integer },
              user_id: { type: :integer },
              status: { type: :string, enum: [ "pending", "confirmed", "shipped", "delivered", "cancelled" ] },
              total_amount: { type: :number, format: :float },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: [ "status", "total_amount" ]
          },
          CartItem: {
            type: :object,
            properties: {
              id: { type: :integer },
              product_id: { type: :integer },
              quantity: { type: :integer },
              price: { type: :number, format: :float },
              subtotal: { type: :number, format: :float }
            },
            required: [ "product_id", "quantity" ]
          },
          Review: {
            type: :object,
            properties: {
              id: { type: :integer },
              product_id: { type: :integer },
              user_id: { type: :integer },
              rating: { type: :integer, minimum: 1, maximum: 5 },
              comment: { type: :string },
              created_at: { type: :string, format: "date-time" }
            },
            required: [ "rating" ]
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string },
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          },
          ValidationError: {
            type: :object,
            properties: {
              errors: {
                type: :object,
                additionalProperties: {
                  type: :array,
                  items: { type: :string }
                }
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
