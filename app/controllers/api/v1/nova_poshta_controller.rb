# frozen_string_literal: true

module Api
  module V1
    class NovaPoshtaController < BaseController
      skip_before_action :authenticate_user!, only: [ :search_cities, :get_warehouses, :get_postomats ]

      # GET /api/v1/nova_poshta/cities?query=Київ
      def search_cities
        query = params[:query].to_s.strip

        if query.blank? || query.length < 2
          return render json: {
            success: false,
            error: "Query must be at least 2 characters"
          }, status: :bad_request
        end

        client = NovaPoshta::ApiClient.new
        cities = client.search_cities(query)

        render json: {
          success: true,
          data: NovaPoshtaCitySerializer.format_collection(cities)
        }
      rescue NovaPoshta::ApiClient::ApiError => e
        render json: {
          success: false,
          error: e.message
        }, status: :service_unavailable
      end

      # GET /api/v1/nova_poshta/warehouses?city_ref=...&type=warehouse
      def get_warehouses
        city_ref = params[:city_ref].to_s.strip
        warehouse_type = params[:type]&.strip

        if city_ref.blank?
          return render json: {
            success: false,
            error: "City reference is required"
          }, status: :bad_request
        end

        client = NovaPoshta::ApiClient.new
        warehouses = client.get_warehouses(city_ref, warehouse_type: warehouse_type)

        render json: {
          success: true,
          data: NovaPoshtaWarehouseSerializer.format_collection(warehouses)
        }
      rescue NovaPoshta::ApiClient::ApiError => e
        render json: {
          success: false,
          error: e.message
        }, status: :service_unavailable
      end

      # GET /api/v1/nova_poshta/postomats?city_ref=...
      def get_postomats
        city_ref = params[:city_ref].to_s.strip

        if city_ref.blank?
          return render json: {
            success: false,
            error: "City reference is required"
          }, status: :bad_request
        end

        client = NovaPoshta::ApiClient.new
        postomats = client.get_postomats(city_ref)

        render json: {
          success: true,
          data: NovaPoshtaPostomatSerializer.format_collection(postomats)
        }
      rescue NovaPoshta::ApiClient::ApiError => e
        render json: {
          success: false,
          error: e.message
        }, status: :service_unavailable
      end
    end
  end
end
