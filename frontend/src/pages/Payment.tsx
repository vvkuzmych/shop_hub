import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Elements } from "@stripe/react-stripe-js";
import { loadStripe } from "@stripe/stripe-js";
import PaymentForm from "../components/PaymentForm";
import { ordersApi } from "../api/orders";
import { paymentsApi } from "../api/payments";
import { CreditCard, ArrowLeft } from "lucide-react";
import styles from "./Payment.module.css";

const stripePromise = loadStripe(import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY || "");

const Payment = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [clientSecret, setClientSecret] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [order, setOrder] = useState<any>(null);

  useEffect(() => {
    if (id) {
      initializePayment();
    }
  }, [id]);

  const initializePayment = async () => {
    try {
      // Fetch order details
      const orderResponse = await ordersApi.getById(id!);
      setOrder(orderResponse.data);

      // Create payment intent
      const paymentResponse = await paymentsApi.createIntent(id!);
      setClientSecret(paymentResponse.client_secret);
      setLoading(false);
    } catch (err: any) {
      setError(err.response?.data?.error || "Failed to initialize payment");
      setLoading(false);
    }
  };

  const appearance = {
    theme: "stripe" as const,
  };

  const options = {
    clientSecret,
    appearance,
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.loadingSkeleton}></div>
          <div className={`${styles.loadingSkeleton} w-2/3`}></div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.errorContainer}>
        <div className={styles.errorCard}>
          <h2 className={styles.errorTitle}>Payment Error</h2>
          <p className={styles.errorMessage}>{error}</p>
          <button onClick={() => navigate("/orders")} className={styles.errorButton}>
            Back to Orders
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <button onClick={() => navigate(`/orders/${id}`)} className={styles.backButton}>
        <ArrowLeft className="w-5 h-5" />
        <span>Back to Order</span>
      </button>

      <div className={styles.grid}>
        <div className={styles.paymentColumn}>
          <div className={styles.card}>
            <div className={styles.header}>
              <CreditCard className={styles.headerIcon} />
              <h1 className={styles.title}>Complete Payment</h1>
            </div>

            {clientSecret && (
              <Elements options={options} stripe={stripePromise}>
                <PaymentForm orderId={id!} />
              </Elements>
            )}
          </div>
        </div>

        <div className={styles.summaryColumn}>
          <div className={styles.summaryCard}>
            <h2 className={styles.summaryTitle}>Order Summary</h2>
            
            {order && (
              <>
                <div className={styles.summaryRow}>
                  <span className={styles.summaryLabel}>Order Number</span>
                  <span className={styles.summaryValue}>#{order.id}</span>
                </div>
                
                <div className={styles.summaryRow}>
                  <span className={styles.summaryLabel}>Total Amount</span>
                  <span className={styles.summaryAmount}>
                    ${parseFloat(order.attributes.total_amount).toFixed(2)}
                  </span>
                </div>

                <div className={styles.secureInfo}>
                  <svg className={styles.secureIcon} fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                  </svg>
                  <span>Secure payment powered by Stripe</span>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Payment;
