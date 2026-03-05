import api from "./axios";

export interface Category {
  id: number;
  name: string;
  description?: string;
  parent_id?: number;
  subcategories?: Array<{
    id: number;
    name: string;
    description?: string;
  }>;
}

export const categoriesApi = {
  getAll: async () => {
    const response = await api.get<Category[]>("/categories");
    return response.data;
  },

  getById: async (id: string) => {
    const response = await api.get<Category>(`/categories/${id}`);
    return response.data;
  },
};
