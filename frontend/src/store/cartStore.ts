import { create } from "zustand";
import type { CartItem } from "../types";

interface CartState {
  items: CartItem[];
  total: number;
  setCart: (items: CartItem[], total: number) => void;
  clearCart: () => void;
  itemCount: () => number;
}

export const useCartStore = create<CartState>((set, get) => ({
  items: [],
  total: 0,
  setCart: (items, total) => set({ items, total }),
  clearCart: () => set({ items: [], total: 0 }),
  itemCount: () => {
    const { items } = get();
    if (!items || !Array.isArray(items)) return 0;
    return items.reduce((sum, item) => sum + item.quantity, 0);
  },
}));
