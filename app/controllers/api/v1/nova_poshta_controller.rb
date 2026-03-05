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

        # Format response for frontend
        formatted_cities = cities.map do |city|
          {
            ref: city["Ref"],
            name: city["Description"],
            name_ru: city["DescriptionRu"],
            area: city["Area"],
            settlement_type: city["SettlementTypeDescription"]
          }
        end

        render json: {
          success: true,
          data: formatted_cities
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

        # Format response for frontend
        formatted_warehouses = warehouses.map do |warehouse|
          {
            ref: warehouse["Ref"],
            number: warehouse["Number"],
            description: warehouse["Description"],
            description_ru: warehouse["DescriptionRu"],
            short_address: warehouse["ShortAddress"],
            short_address_ru: warehouse["ShortAddressRu"],
            type_of_warehouse: warehouse["TypeOfWarehouse"],
            category_of_warehouse: warehouse["CategoryOfWarehouse"],
            latitude: warehouse["Latitude"],
            longitude: warehouse["Longitude"],
            reception: warehouse["Reception"],
            delivery: warehouse["Delivery"],
            schedule: warehouse["Schedule"]
          }
        end

        render json: {
          success: true,
          data: formatted_warehouses
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

        # Format response for frontend
        formatted_postomats = postomats.map do |postomat|
          {
            ref: postomat["Ref"],
            number: postomat["Number"],
            description: postomat["Description"],
            description_ru: postomat["DescriptionRu"],
            short_address: postomat["ShortAddress"],
            short_address_ru: postomat["ShortAddressRu"],
            latitude: postomat["Latitude"],
            longitude: postomat["Longitude"],
            reception: postomat["Reception"],
            delivery: postomat["Delivery"],
            schedule: postomat["Schedule"]
          }
        end

        render json: {
          success: true,
          data: formatted_postomats
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
