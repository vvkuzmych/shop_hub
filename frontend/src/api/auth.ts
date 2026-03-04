import api from "./axios";
import type { User } from "../types";

export interface SignupData {
  email: string;
  password: string;
  password_confirmation: string;
  first_name: string;
  last_name: string;
}

export interface LoginData {
  email: string;
  password: string;
}

export interface AuthResponse {
  message: string;
  user: User;
}

export const authApi = {
  signup: async (data: SignupData) => {
    const response = await api.post<AuthResponse>("/signup", { user: data });
    return response.data;
  },

  login: async (data: LoginData) => {
    const response = await api.post<AuthResponse>("/login", { user: data });
    return response.data;
  },

  logout: async () => {
    const response = await api.delete("/logout");
    return response.data;
  },
};
