import api from "./axios";

export interface NovaPoshtaCity {
  ref: string;
  name: string;
  name_ru: string;
  area: string;
  settlement_type: string;
}

export interface NovaPoshtaWarehouse {
  ref: string;
  number: string;
  description: string;
  description_ru: string;
  short_address: string;
  short_address_ru: string;
  type_of_warehouse: string;
  category_of_warehouse: string;
  latitude: string;
  longitude: string;
  reception: any;
  delivery: any;
  schedule: any;
}

export interface NovaPoshtaPostomat {
  ref: string;
  number: string;
  description: string;
  description_ru: string;
  short_address: string;
  short_address_ru: string;
  latitude: string;
  longitude: string;
  reception: any;
  delivery: any;
  schedule: any;
}

interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
}

export const novaPoshtaApi = {
  searchCities: async (query: string): Promise<NovaPoshtaCity[]> => {
    if (!query || query.length < 2) {
      return [];
    }

    try {
      const response = await api.get<ApiResponse<NovaPoshtaCity[]>>("/nova_poshta/cities", {
        params: { query },
      });
      
      if (response.data.success && response.data.data) {
        return response.data.data;
      }
      
      return [];
    } catch (error) {
      console.error("Failed to search cities:", error);
      return [];
    }
  },

  getWarehouses: async (cityRef: string, type?: string): Promise<NovaPoshtaWarehouse[]> => {
    if (!cityRef) {
      return [];
    }

    try {
      const response = await api.get<ApiResponse<NovaPoshtaWarehouse[]>>("/nova_poshta/warehouses", {
        params: { city_ref: cityRef, type },
      });
      
      if (response.data.success && response.data.data) {
        return response.data.data;
      }
      
      return [];
    } catch (error) {
      console.error("Failed to get warehouses:", error);
      return [];
    }
  },

  getPostomats: async (cityRef: string): Promise<NovaPoshtaPostomat[]> => {
    if (!cityRef) {
      return [];
    }

    try {
      const response = await api.get<ApiResponse<NovaPoshtaPostomat[]>>("/nova_poshta/postomats", {
        params: { city_ref: cityRef },
      });
      
      if (response.data.success && response.data.data) {
        return response.data.data;
      }
      
      return [];
    } catch (error) {
      console.error("Failed to get postomats:", error);
      return [];
    }
  },
};
