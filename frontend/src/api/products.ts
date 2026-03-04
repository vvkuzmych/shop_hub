import api from "./axios";
import type { Product, ApiResponse } from "../types";

export interface ProductFilters {
  q?: string;
  category_id?: string;
  min_price?: number;
  max_price?: number;
  in_stock?: boolean;
  featured?: boolean;
  page?: number;
  per_page?: number;
}

export const productsApi = {
  getAll: async (filters?: ProductFilters) => {
    const response = await api.get<ApiResponse<Product[]>>("/products", {
      params: filters,
    });
    return response.data;
  },

  getById: async (id: string) => {
    const response = await api.get<{ data: Product }>(`/products/${id}`);
    return response.data;
  },

  search: async (query: string, page = 1) => {
    const response = await api.get<ApiResponse<Product[]>>("/products/search", {
      params: { q: query, page },
    });
    return response.data;
  },

  getFeatured: async (limit = 10) => {
    const response = await api.get<ApiResponse<Product[]>>("/products/featured", {
      params: { limit },
    });
    return response.data;
  },
};
