# frozen_string_literal: true

# Nova Poshta API Client
# Documentation: https://developers.novaposhta.ua/
# API URL: https://api.novaposhta.ua/v2.0/json/

module NovaPoshta
  class ApiClient
    API_URL = "https://api.novaposhta.ua/v2.0/json/"

    class ApiError < StandardError; end

    def initialize
      @api_key = ENV["NOVA_POSHTA_API_KEY"] || ""
    end

    # Search cities by name
    # @param query [String] City name search query (min 2 characters)
    # @return [Array<Hash>] List of cities with Ref, Description, DescriptionRu, Area, etc.
    def search_cities(query)
      return [] if query.blank? || query.length < 2

      response = make_request(
        model_name: "Address",
        called_method: "getCities",
        method_properties: {
          FindByString: query,
          Limit: "20"
        }
      )

      response["data"] || []
    end

    # Get warehouses by city reference
    # @param city_ref [String] City reference ID from getCities
    # @param warehouse_type [String] Optional: "Warehouse", "Postomat", "PUDO"
    # @return [Array<Hash>] List of warehouses/branches
    def get_warehouses(city_ref, warehouse_type: nil)
      return [] if city_ref.blank?

      method_properties = {
        CityRef: city_ref,
        Limit: "100"
      }

      # Filter by type if specified
      method_properties[:TypeOfWarehouseRef] = warehouse_type if warehouse_type.present?

      response = make_request(
        model_name: "Address",
        called_method: "getWarehouses",
        method_properties: method_properties
      )

      response["data"] || []
    end

    # Get parcel machines (Postomats) by city reference
    # @param city_ref [String] City reference ID
    # @return [Array<Hash>] List of postomats
    def get_postomats(city_ref)
      return [] if city_ref.blank?

      response = make_request(
        model_name: "Address",
        called_method: "getWarehouses",
        method_properties: {
          CityRef: city_ref,
          CategoryOfWarehouse: "Postomat", # Filter by Postomat category
          Limit: "100"
        }
      )

      response["data"] || []
    end

    # Get warehouse types
    # @return [Array<Hash>] List of warehouse types
    def get_warehouse_types
      response = make_request(
        model_name: "Address",
        called_method: "getWarehouseTypes"
      )

      response["data"] || []
    end

    private

    def make_request(model_name:, called_method:, method_properties: {})
      uri = URI(API_URL)

      request_body = {
        apiKey: @api_key,
        modelName: model_name,
        calledMethod: called_method,
        methodProperties: method_properties
      }

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 10

      request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
      request.body = request_body.to_json

      response = http.request(request)
      parsed_response = JSON.parse(response.body)

      # Check for errors
      if parsed_response["success"] == false
        errors = parsed_response["errors"]&.join(", ") || "Unknown error"
        Rails.logger.error("Nova Poshta API Error: #{errors}")
        raise ApiError, "Nova Poshta API Error: #{errors}"
      end

      parsed_response
    rescue JSON::ParserError => e
      Rails.logger.error("Nova Poshta API JSON Parse Error: #{e.message}")
      raise ApiError, "Invalid API response"
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error("Nova Poshta API Timeout: #{e.message}")
      raise ApiError, "API request timeout"
    rescue StandardError => e
      Rails.logger.error("Nova Poshta API Error: #{e.message}")
      raise ApiError, "API request failed: #{e.message}"
    end
  end
end
