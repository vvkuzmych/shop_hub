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

export interface CreateProductData {
  name: string;
  description: string;
  price: number;
  stock: number;
  category_id: number;
  sku?: string;
  active?: boolean;
  images?: File[];
}

export interface UpdateProductData extends Partial<CreateProductData> {}

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

  create: async (data: CreateProductData) => {
    const formData = new FormData();
    formData.append("product[name]", data.name);
    formData.append("product[description]", data.description);
    formData.append("product[price]", data.price.toString());
    formData.append("product[stock]", data.stock.toString());
    formData.append("product[category_id]", data.category_id.toString());
    
    if (data.sku) formData.append("product[sku]", data.sku);
    if (data.active !== undefined) formData.append("product[active]", data.active.toString());
    
    if (data.images) {
      data.images.forEach((image) => {
        formData.append("product[images][]", image);
      });
    }

    const response = await api.post<{ data: Product }>("/products", formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return response.data;
  },

  update: async (id: string, data: UpdateProductData) => {
    const formData = new FormData();
    
    if (data.name) formData.append("product[name]", data.name);
    if (data.description) formData.append("product[description]", data.description);
    if (data.price !== undefined) formData.append("product[price]", data.price.toString());
    if (data.stock !== undefined) formData.append("product[stock]", data.stock.toString());
    if (data.category_id) formData.append("product[category_id]", data.category_id.toString());
    if (data.sku) formData.append("product[sku]", data.sku);
    if (data.active !== undefined) formData.append("product[active]", data.active.toString());
    
    if (data.images) {
      data.images.forEach((image) => {
        formData.append("product[images][]", image);
      });
    }

    const response = await api.patch<{ data: Product }>(`/products/${id}`, formData, {
      headers: { "Content-Type": "multipart/form-data" },
    });
    return response.data;
  },

  delete: async (id: string) => {
    await api.delete(`/products/${id}`);
  },
};
