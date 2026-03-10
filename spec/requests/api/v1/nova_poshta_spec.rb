require "rails_helper"

RSpec.describe "Api::V1::NovaPoshta", type: :request do
  let(:api_client) { instance_double(NovaPoshta::ApiClient) }

  before do
    allow(NovaPoshta::ApiClient).to receive(:new).and_return(api_client)
  end

  describe "GET /api/v1/nova_poshta/cities" do
    let(:mock_cities) do
      [
        {
          "Ref" => "e71abb60-4b33-11de-b2ad-00215aee3ebe",
          "Description" => "Київ",
          "DescriptionRu" => "Киев",
          "Area" => "Київська область",
          "SettlementTypeDescription" => "місто"
        },
        {
          "Ref" => "db5c88e0-391c-11dd-90d9-001a92567626",
          "Description" => "Львів",
          "DescriptionRu" => "Львов",
          "Area" => "Львівська область",
          "SettlementTypeDescription" => "місто"
        }
      ]
    end

    context "with valid query" do
      it "returns formatted cities" do
        allow(api_client).to receive(:search_cities).with("Київ").and_return(mock_cities)

        get "/api/v1/nova_poshta/cities", params: { query: "Київ" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["data"].size).to eq(2)
        expect(json["data"].first["name"]).to eq("Київ")
        expect(json["data"].first["ref"]).to eq("e71abb60-4b33-11de-b2ad-00215aee3ebe")
      end
    end

    context "with short query" do
      it "returns error" do
        get "/api/v1/nova_poshta/cities", params: { query: "К" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("Query must be at least 2 characters")
      end
    end

    context "with empty query" do
      it "returns error" do
        get "/api/v1/nova_poshta/cities", params: { query: "" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
      end
    end

    context "when API error occurs" do
      it "returns service unavailable" do
        allow(api_client).to receive(:search_cities).and_raise(NovaPoshta::ApiClient::ApiError.new("API Error"))

        get "/api/v1/nova_poshta/cities", params: { query: "Test" }

        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("API Error")
      end
    end
  end

  describe "GET /api/v1/nova_poshta/warehouses" do
    let(:mock_warehouses) do
      [
        {
          "Ref" => "warehouse-ref-1",
          "Number" => "1",
          "Description" => "Відділення №1: вул. Хрещатик, 1",
          "DescriptionRu" => "Отделение №1: ул. Крещатик, 1",
          "ShortAddress" => "Київ, вул. Хрещатик, 1",
          "ShortAddressRu" => "Киев, ул. Крещатик, 1",
          "TypeOfWarehouse" => "9a68df70-0267-42a8-bb5c-37f427e36ee4",
          "CategoryOfWarehouse" => "Branch",
          "Latitude" => "50.4501",
          "Longitude" => "30.5234",
          "Reception" => {},
          "Delivery" => {},
          "Schedule" => {}
        }
      ]
    end

    context "with valid city_ref" do
      it "returns formatted warehouses" do
        city_ref = "e71abb60-4b33-11de-b2ad-00215aee3ebe"
        allow(api_client).to receive(:get_warehouses).with(city_ref, warehouse_type: nil).and_return(mock_warehouses)

        get "/api/v1/nova_poshta/warehouses", params: { city_ref: city_ref }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["data"].size).to eq(1)
        expect(json["data"].first["number"]).to eq("1")
        expect(json["data"].first["latitude"]).to eq("50.4501")
      end

      it "passes warehouse_type parameter" do
        city_ref = "e71abb60-4b33-11de-b2ad-00215aee3ebe"
        allow(api_client).to receive(:get_warehouses).with(city_ref, warehouse_type: "Branch").and_return(mock_warehouses)

        get "/api/v1/nova_poshta/warehouses", params: { city_ref: city_ref, type: "Branch" }

        expect(response).to have_http_status(:ok)
      end
    end

    context "with missing city_ref" do
      it "returns error" do
        get "/api/v1/nova_poshta/warehouses", params: { city_ref: "" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("City reference is required")
      end
    end

    context "when API error occurs" do
      it "returns service unavailable" do
        city_ref = "invalid-ref"
        allow(api_client).to receive(:get_warehouses).and_raise(NovaPoshta::ApiClient::ApiError.new("Invalid city"))

        get "/api/v1/nova_poshta/warehouses", params: { city_ref: city_ref }

        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("Invalid city")
      end
    end
  end

  describe "GET /api/v1/nova_poshta/postomats" do
    let(:mock_postomats) do
      [
        {
          "Ref" => "postomat-ref-1",
          "Number" => "5001",
          "Description" => "Поштомат №5001: вул. Саксаганського, 10",
          "DescriptionRu" => "Почтомат №5001: ул. Саксаганского, 10",
          "ShortAddress" => "Київ, вул. Саксаганського, 10",
          "ShortAddressRu" => "Киев, ул. Саксаганского, 10",
          "Latitude" => "50.4401",
          "Longitude" => "30.5189",
          "Reception" => {},
          "Delivery" => {},
          "Schedule" => {}
        }
      ]
    end

    context "with valid city_ref" do
      it "returns formatted postomats" do
        city_ref = "e71abb60-4b33-11de-b2ad-00215aee3ebe"
        allow(api_client).to receive(:get_postomats).with(city_ref).and_return(mock_postomats)

        get "/api/v1/nova_poshta/postomats", params: { city_ref: city_ref }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be true
        expect(json["data"].size).to eq(1)
        expect(json["data"].first["number"]).to eq("5001")
        expect(json["data"].first["description"]).to eq("Поштомат №5001: вул. Саксаганського, 10")
      end
    end

    context "with missing city_ref" do
      it "returns error" do
        get "/api/v1/nova_poshta/postomats", params: { city_ref: "" }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("City reference is required")
      end
    end

    context "when API error occurs" do
      it "returns service unavailable" do
        city_ref = "invalid-ref"
        allow(api_client).to receive(:get_postomats).and_raise(NovaPoshta::ApiClient::ApiError.new("API Error"))

        get "/api/v1/nova_poshta/postomats", params: { city_ref: city_ref }

        expect(response).to have_http_status(:service_unavailable)
        json = JSON.parse(response.body)
        expect(json["success"]).to be false
        expect(json["error"]).to eq("API Error")
      end
    end
  end
end
