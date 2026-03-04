import { useState } from "react";
import {
  PaymentElement,
  useStripe,
  useElements,
} from "@stripe/react-stripe-js";
import styles from "./PaymentForm.module.css";

interface PaymentFormProps {
  orderId: string;
}

const PaymentForm = ({ orderId }: PaymentFormProps) => {
  const stripe = useStripe();
  const elements = useElements();

  const [message, setMessage] = useState("");
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!stripe || !elements) {
      return;
    }

    setIsLoading(true);

    const { error } = await stripe.confirmPayment({
      elements,
      confirmParams: {
        return_url: `${window.location.origin}/orders/${orderId}/track`,
      },
    });

    if (error) {
      if (error.type === "card_error" || error.type === "validation_error") {
        setMessage(error.message || "An error occurred");
      } else {
        setMessage("An unexpected error occurred.");
      }
    }

    setIsLoading(false);
  };

  const paymentElementOptions = {
    layout: "tabs" as const,
  };

  return (
    <form onSubmit={handleSubmit} className={styles.form}>
      <PaymentElement options={paymentElementOptions} />
      
      <button
        disabled={isLoading || !stripe || !elements}
        className={styles.submitButton}
      >
        <span>
          {isLoading ? "Processing..." : "Pay Now"}
        </span>
      </button>
      
      {message && (
        <div className={styles.message}>{message}</div>
      )}
    </form>
  );
};

export default PaymentForm;
