require "rails_helper"

RSpec.describe "Api::V1::Reviews", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/products/:product_id/reviews" do
    let!(:review1) { create(:review, product: product, user: user, rating: 5) }
    let!(:review2) { create(:review, product: product, rating: 4) }

    it "returns all reviews for a product" do
      get "/api/v1/products/#{product.id}/reviews"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(2)
      expect(json.first["rating"]).to be_in([ 4, 5 ])
    end
  end

  describe "POST /api/v1/products/:product_id/reviews" do
    context "when authenticated" do
      context "with valid parameters" do
        it "creates a new review" do
          expect {
            post "/api/v1/products/#{product.id}/reviews", params: {
              review: {
                rating: 5,
                comment: "Great product!"
              }
            }, headers: headers
          }.to change(Review, :count).by(1)

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["message"]).to eq("Review created successfully")
        end
      end

      context "with invalid parameters" do
        it "returns errors for invalid rating" do
          post "/api/v1/products/#{product.id}/reviews", params: {
            review: {
              rating: 10,
              comment: "Invalid rating"
            }
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["errors"]).to be_present
        end

        it "prevents duplicate reviews from same user" do
          create(:review, product: product, user: user)

          post "/api/v1/products/#{product.id}/reviews", params: {
            review: {
              rating: 5,
              comment: "Another review"
            }
          }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context "when not authenticated" do
      it "returns unauthorized" do
        post "/api/v1/products/#{product.id}/reviews", params: {
          review: {
            rating: 5,
            comment: "Great product!"
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
