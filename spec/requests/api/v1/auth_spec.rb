require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/signup" do
    let(:valid_attributes) do
      {
        user: {
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          first_name: "John",
          last_name: "Doe"
        }
      }
    end

    let(:invalid_attributes) do
      {
        user: {
          email: "invalid",
          password: "123",
          password_confirmation: "456",
          first_name: "",
          last_name: ""
        }
      }
    end

    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post "/api/v1/signup", params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "returns JWT token in Authorization header" do
        post "/api/v1/signup", params: valid_attributes
        expect(response).to have_http_status(:created)
        expect(response.headers["Authorization"]).to be_present

        json = JSON.parse(response.body)
        expect(json["user"]["email"]).to eq("newuser@example.com")
      end

      it "sets user role to customer by default" do
        post "/api/v1/signup", params: valid_attributes
        user = User.last
        expect(user.customer?).to be true
      end
    end

    context "with invalid parameters" do
      it "does not create a new user" do
        expect {
          post "/api/v1/signup", params: invalid_attributes
        }.not_to change(User, :count)
      end

      it "returns validation errors" do
        post "/api/v1/signup", params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_content)

        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end

  describe "POST /api/v1/login" do
    let!(:user) do
      User.create!(
        email: "test@example.com",
        password: "password123",
        password_confirmation: "password123",
        first_name: "Test",
        last_name: "User"
      )
    end

    context "with valid credentials" do
      it "returns JWT token in Authorization header" do
        post "/api/v1/login", params: {
          user: {
            email: "test@example.com",
            password: "password123"
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.headers["Authorization"]).to be_present

        json = JSON.parse(response.body)
        expect(json["user"]["email"]).to eq("test@example.com")
      end
    end

    context "with invalid email" do
      it "returns unauthorized" do
        post "/api/v1/login", params: {
          user: {
            email: "wrong@example.com",
            password: "password123"
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid password" do
      it "returns unauthorized" do
        post "/api/v1/login", params: {
          user: {
            email: "test@example.com",
            password: "wrongpassword"
          }
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/logout" do
    let!(:user) do
      User.create!(
        email: "test@example.com",
        password: "password123",
        first_name: "Test",
        last_name: "User"
      )
    end

    context "when authenticated" do
      it "logs out successfully" do
        # Login first to get token
        post "/api/v1/login", params: {
          user: {
            email: "test@example.com",
            password: "password123"
          }
        }

        token = response.headers["Authorization"]

        # Logout with token
        delete "/api/v1/logout", headers: { "Authorization" => token }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Logged out successfully")
      end
    end
  end

  describe "POST /api/v1/password (Forgot Password)" do
    let!(:user) do
      User.create!(
        email: "test@example.com",
        password: "password123",
        first_name: "Test",
        last_name: "User"
      )
    end

    context "with valid email" do
      it "sends password reset instructions" do
        post "/api/v1/password", params: {
          user: {
            email: "test@example.com"
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to include("Password reset instructions")

        # Verify reset token was generated
        user.reload
        expect(user.reset_password_token).to be_present
      end
    end

    context "with invalid email" do
      it "returns not found" do
        post "/api/v1/password", params: {
          user: {
            email: "nonexistent@example.com"
          }
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PUT /api/v1/password (Reset Password)" do
    let!(:user) do
      User.create!(
        email: "test@example.com",
        password: "oldpassword123",
        first_name: "Test",
        last_name: "User"
      )
    end

    before do
      # Generate reset token
      user.send_reset_password_instructions
    end

    context "with valid reset token" do
      it "resets the password" do
        raw_token = user.send_reset_password_instructions
        user.reload

        put "/api/v1/password", params: {
          user: {
            reset_password_token: raw_token,
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to include("Password has been reset successfully")

        # Verify can login with new password
        expect(user.reload.valid_password?("newpassword123")).to be true
      end
    end

    context "with invalid reset token" do
      it "returns error" do
        put "/api/v1/password", params: {
          user: {
            reset_password_token: "invalid_token",
            password: "newpassword123",
            password_confirmation: "newpassword123"
          }
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end
