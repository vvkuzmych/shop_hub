export interface User {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  full_name: string;
  role: "customer" | "admin";
}

export interface Product {
  id: string;
  type: "product";
  attributes: {
    name: string;
    description: string;
    price: string;
    stock: number;
    sku: string;
    active: boolean;
    featured: boolean;
    average_rating: number;
    in_stock: boolean;
    image_urls: string[];
  };
  relationships: {
    category: {
      data: {
        id: string;
        type: "category";
      };
    };
  };
}

export interface Category {
  id: string;
  type: "category";
  attributes: {
    name: string;
    description: string;
  };
}

export interface CartItem {
  product_id: number;
  name: string;
  price: number;
  quantity: number;
  subtotal: number;
  stock: number;
}

export interface Order {
  id: string;
  type: "order";
  attributes: {
    status: string;
    total_amount: string;
    created_at: string;
    updated_at: string;
  };
  relationships: {
    user: {
      data: {
        id: string;
        type: "user";
      };
    };
    order_items: {
      data: Array<{
        id: string;
        type: "order_item";
      }>;
    };
  };
}

export interface Review {
  id: string;
  type: "review";
  attributes: {
    rating: number;
    comment: string;
    created_at: string;
  };
}

export interface ApiResponse<T> {
  data: T;
  meta?: {
    current_page: number;
    next_page: number | null;
    prev_page: number | null;
    total_pages: number;
    total_count: number;
  };
}
