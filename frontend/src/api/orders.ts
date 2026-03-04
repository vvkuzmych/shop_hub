import api from "./axios";
import type { Order, ApiResponse } from "../types";

export interface CreateOrderData {
  items: Array<{
    product_id: number;
    quantity: number;
  }>;
}

export const ordersApi = {
  getAll: async (page = 1) => {
    const response = await api.get<ApiResponse<Order[]>>("/orders", {
      params: { page },
    });
    return response.data;
  },

  getById: async (id: string) => {
    const response = await api.get<{ data: Order }>(`/orders/${id}`);
    return response.data;
  },

  create: async (data: CreateOrderData) => {
    const response = await api.post<{ data: Order }>("/orders", data);
    return response.data;
  },

  cancel: async (id: string) => {
    const response = await api.patch<{ data: Order }>(`/orders/${id}/cancel`);
    return response.data;
  },
};
