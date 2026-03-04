require "rails_helper"

RSpec.describe Api::V1::ProductsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET #index" do
    it "returns list of products" do
      products = FactoryBot.create_list(:product, 3)

      get :index

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(3)
    end

    it "paginates results" do
      create_list(:product, 25)

      get :index, params: { page: 1, per_page: 10 }

      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(10)
    end
  end

  describe "POST #create" do
    context "as admin" do
      before { sign_in admin }

      it "creates a new product" do
        category = create(:category)
        product_params = attributes_for(:product, category_id: category.id)

        expect {
          post :create, params: { product: product_params }
        }.to change(Product, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "as customer" do
      before { sign_in user }

      it "denies access" do
        post :create, params: { product: attributes_for(:product) }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
