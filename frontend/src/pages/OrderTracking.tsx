import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
import { ordersApi, type TrackingData } from "../api/orders";
import { 
  Package, Calendar, MapPin, Truck, CheckCircle, 
  Clock, Box, Home, Store, CreditCard 
} from "lucide-react";
import styles from "./OrderTracking.module.css";

const OrderTracking = () => {
  const { id } = useParams<{ id: string }>();
  const [tracking, setTracking] = useState<TrackingData["data"] | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      fetchTracking();
    }
  }, [id]);

  const fetchTracking = async () => {
    try {
      const response = await ordersApi.track(id!);
      setTracking(response.data);
    } catch (error) {
      console.error("Failed to fetch tracking:", error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusSteps = (deliveryMethod: string) => {
    if (deliveryMethod === "pickup") {
      return [
        { key: "pending", label: "Order Placed", icon: Package },
        { key: "payment_received", label: "Payment Received", icon: CreditCard },
        { key: "processing", label: "Processing", icon: Clock },
        { key: "packed", label: "Packed", icon: Box },
        { key: "ready_for_pickup", label: "Ready for Pickup", icon: Store },
        { key: "picked_up", label: "Picked Up", icon: CheckCircle },
      ];
    }
    
    return [
      { key: "pending", label: "Order Placed", icon: Package },
      { key: "payment_received", label: "Payment Received", icon: CreditCard },
      { key: "processing", label: "Processing", icon: Clock },
      { key: "packed", label: "Packed", icon: Box },
      { key: "shipped", label: "Shipped", icon: Truck },
      { key: "out_for_delivery", label: "Out for Delivery", icon: MapPin },
      { key: "delivered", label: "Delivered", icon: CheckCircle },
    ];
  };

  const getStatusIndex = (status: string, steps: any[]) => {
    return steps.findIndex(step => step.key === status);
  };

  const getPaymentStatusColor = (status: string) => {
    const colors: Record<string, string> = {
      unpaid: styles.paymentUnpaid,
      pending: styles.paymentPending,
      paid: styles.paymentPaid,
      failed: styles.paymentFailed,
      refunded: styles.paymentRefunded,
    };
    return colors[status] || styles.paymentUnpaid;
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.loadingSkeleton}></div>
          <div className={`${styles.loadingSkeleton} w-3/4`}></div>
          <div className={`${styles.loadingSkeleton} w-1/2`}></div>
        </div>
      </div>
    );
  }

  if (!tracking) {
    return (
      <div className={styles.notFoundContainer}>
        <Package className={styles.notFoundIcon} />
        <h2 className={styles.notFoundTitle}>Order Not Found</h2>
        <Link to="/orders" className={styles.notFoundLink}>
          Back to Orders →
        </Link>
      </div>
    );
  }

  const steps = getStatusSteps(tracking.delivery_method);
  const currentStepIndex = getStatusIndex(tracking.status, steps);
  const isCancelled = tracking.status === "cancelled";

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Track Order #{tracking.id}</h1>
          <p className={styles.subtitle}>
            Order placed on {new Date(tracking.created_at).toLocaleDateString()}
          </p>
        </div>
        
        <Link to={`/orders/${tracking.id}`} className={styles.viewDetailsButton}>
          View Full Details
        </Link>
      </div>

      <div className={styles.grid}>
        {/* Progress Section */}
        <div className={styles.progressColumn}>
          <div className={styles.card}>
            <div className={styles.progressHeader}>
              <h2 className={styles.cardTitle}>Order Progress</h2>
              <div className={styles.progressPercentage}>
                {isCancelled ? "Cancelled" : `${tracking.progress_percentage}%`}
              </div>
            </div>

            {!isCancelled && (
              <div className={styles.progressBar}>
                <div 
                  className={styles.progressBarFill} 
                  style={{ width: `${tracking.progress_percentage}%` }}
                ></div>
              </div>
            )}

            <div className={styles.timeline}>
              {steps.map((step, index) => {
                const Icon = step.icon;
                const isCompleted = index <= currentStepIndex;
                const isCurrent = index === currentStepIndex;
                
                return (
                  <div key={step.key} className={styles.timelineItem}>
                    <div className={styles.timelineIconWrapper}>
                      <div 
                        className={`${styles.timelineIcon} ${
                          isCompleted ? styles.timelineIconCompleted : 
                          isCurrent ? styles.timelineIconCurrent : 
                          styles.timelineIconPending
                        }`}
                      >
                        <Icon className="w-5 h-5" />
                      </div>
                      {index < steps.length - 1 && (
                        <div 
                          className={`${styles.timelineLine} ${
                            isCompleted ? styles.timelineLineCompleted : styles.timelineLinePending
                          }`}
                        ></div>
                      )}
                    </div>
                    
                    <div className={styles.timelineContent}>
                      <div className={`${styles.timelineLabel} ${isCurrent ? styles.timelineLabelCurrent : ""}`}>
                        {step.label}
                      </div>
                      {isCurrent && (
                        <div className={styles.timelineBadge}>Current Status</div>
                      )}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>

        {/* Info Section */}
        <div className={styles.infoColumn}>
          <div className={styles.card}>
            <h2 className={styles.cardTitle}>Order Information</h2>
            
            <div className={styles.infoGrid}>
              <div className={styles.infoItem}>
                <div className={styles.infoLabel}>Payment Status</div>
                <div className={`${styles.paymentBadge} ${getPaymentStatusColor(tracking.payment_status)}`}>
                  {tracking.payment_status.replace("_", " ").toUpperCase()}
                </div>
              </div>
              
              <div className={styles.infoItem}>
                <div className={styles.infoLabel}>Delivery Method</div>
                <div className={styles.infoValue}>
                  {tracking.delivery_method === "delivery" ? (
                    <>
                      <Home className="w-4 h-4" />
                      <span>Home Delivery</span>
                    </>
                  ) : (
                    <>
                      <Store className="w-4 h-4" />
                      <span>Store Pickup</span>
                    </>
                  )}
                </div>
              </div>
              
              <div className={styles.infoItem}>
                <div className={styles.infoLabel}>Total Amount</div>
                <div className={styles.infoAmount}>
                  ${typeof tracking.total_amount === 'string' 
                    ? parseFloat(tracking.total_amount).toFixed(2)
                    : tracking.total_amount.toFixed(2)
                  }
                </div>
              </div>
              
              {tracking.tracking_number && (
                <div className={styles.infoItem}>
                  <div className={styles.infoLabel}>Tracking Number</div>
                  <div className={styles.infoTracking}>{tracking.tracking_number}</div>
                </div>
              )}
              
              {tracking.estimated_delivery_date && (
                <div className={styles.infoItem}>
                  <div className={styles.infoLabel}>Estimated Delivery</div>
                  <div className={styles.infoValue}>
                    <Calendar className="w-4 h-4" />
                    <span>
                      {new Date(tracking.estimated_delivery_date).toLocaleDateString("en-US", {
                        month: "long",
                        day: "numeric",
                        year: "numeric",
                      })}
                    </span>
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className={styles.helpCard}>
            <h3 className={styles.helpTitle}>Need Help?</h3>
            <p className={styles.helpText}>
              If you have any questions about your order, please contact our customer support.
            </p>
            <Link to="/support" className={styles.helpButton}>
              Contact Support
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OrderTracking;
