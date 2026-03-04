import api from "./axios";

export interface PaymentIntent {
  client_secret: string;
  payment_intent_id: string;
}

export const paymentsApi = {
  createIntent: async (orderId: string) => {
    const response = await api.post<PaymentIntent>("/payments/create_intent", {
      order_id: orderId,
    });
    return response.data;
  },
};
