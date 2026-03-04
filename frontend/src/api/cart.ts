import api from "./axios";
import type { CartItem } from "../types";

export interface CartResponse {
  cart_items: CartItem[];
  total: number;
}

export const cartApi = {
  getItems: async () => {
    const response = await api.get<CartResponse>("/cart/items");
    return response.data;
  },

  addItem: async (productId: number, quantity: number) => {
    const response = await api.post<CartResponse>("/cart/add_item", {
      product_id: productId,
      quantity,
    });
    return response.data;
  },

  updateQuantity: async (productId: number, quantity: number) => {
    const response = await api.patch<CartResponse>("/cart/update_quantity", {
      product_id: productId,
      quantity,
    });
    return response.data;
  },

  removeItem: async (productId: number) => {
    const response = await api.delete<CartResponse>("/cart/remove_item", {
      data: { product_id: productId },
    });
    return response.data;
  },

  clearCart: async () => {
    const response = await api.delete<{ message: string }>("/cart/clear");
    return response.data;
  },
};
