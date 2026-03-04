import { useEffect, useState } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { ordersApi } from "../api/orders";
import { Package, Calendar, DollarSign, ArrowLeft, CheckCircle, XCircle } from "lucide-react";
import styles from "./OrderDetail.module.css";

interface OrderItem {
  id: string;
  product_name: string;
  quantity: number;
  price: number;
  subtotal: number;
}

interface OrderDetailData {
  id: string;
  status: string;
  total_amount: number;
  created_at: string;
  updated_at: string;
  items: OrderItem[];
}

const OrderDetail = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [order, setOrder] = useState<OrderDetailData | null>(null);
  const [loading, setLoading] = useState(true);
  const [canceling, setCanceling] = useState(false);

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    if (!id) return;
    
    try {
      const response = await ordersApi.getById(id);
      
      // Parse JSON:API format
      const orderData = response.data;
      const included = (response as any).included || [];
      
      // Find order_items from included array
      const orderItems = included
        .filter((item: any) => item.type === "order_item")
        .map((orderItem: any) => {
          // Find the related product
          const productId = orderItem.relationships?.product?.data?.id;
          const product = included.find(
            (inc: any) => inc.type === "product" && inc.id === productId
          );
          
          return {
            id: orderItem.id,
            product_name: product?.attributes?.name || "Unknown Product",
            quantity: orderItem.attributes.quantity,
            price: orderItem.attributes.price,
            subtotal: orderItem.attributes.subtotal,
          };
        });
      
      setOrder({
        id: orderData.id,
        status: orderData.attributes.status,
        total_amount: typeof orderData.attributes.total_amount === 'string' 
          ? parseFloat(orderData.attributes.total_amount) 
          : orderData.attributes.total_amount,
        created_at: orderData.attributes.created_at,
        updated_at: orderData.attributes.updated_at,
        items: orderItems,
      });
    } catch (error) {
      console.error("Failed to fetch order:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async () => {
    if (!id || !window.confirm("Are you sure you want to cancel this order?")) return;

    setCanceling(true);
    try {
      await ordersApi.cancel(id);
      await fetchOrder();
    } catch (error) {
      console.error("Failed to cancel order:", error);
      alert("Failed to cancel order. Please try again.");
    } finally {
      setCanceling(false);
    }
  };

  const getStatusClass = (status: string) => {
    const statusMap: Record<string, string> = {
      pending: styles.statusPending,
      confirmed: styles.statusConfirmed,
      shipped: styles.statusShipped,
      delivered: styles.statusDelivered,
      cancelled: styles.statusCancelled,
    };
    return statusMap[status] || styles.statusPending;
  };

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "delivered":
        return <CheckCircle className="w-6 h-6" />;
      case "cancelled":
        return <XCircle className="w-6 h-6" />;
      default:
        return <Package className="w-6 h-6" />;
    }
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.loadingSkeleton}></div>
          <div className={`${styles.loadingSkeleton} w-2/3`}></div>
          <div className={`${styles.loadingSkeleton} w-1/2`}></div>
        </div>
      </div>
    );
  }

  if (!order) {
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

  return (
    <div className={styles.container}>
      <button onClick={() => navigate("/orders")} className={styles.backButton}>
        <ArrowLeft className="w-5 h-5" />
        <span>Back to Orders</span>
      </button>

      <div className={styles.card}>
        <div className={styles.header}>
          <div className={styles.titleSection}>
            <h1 className={styles.title}>Order #{order.id}</h1>
            <div className={styles.statusRow}>
              <span className={`${styles.statusBadge} ${getStatusClass(order.status)}`}>
                {getStatusIcon(order.status)}
                <span>{order.status.toUpperCase()}</span>
              </span>
            </div>
          </div>

          {order.status === "pending" && (
            <button
              onClick={handleCancel}
              disabled={canceling}
              className={styles.cancelButton}
            >
              <XCircle className="w-5 h-5" />
              <span>{canceling ? "Canceling..." : "Cancel Order"}</span>
            </button>
          )}
        </div>

        <div className={styles.metaSection}>
          <div className={styles.metaItem}>
            <Calendar className={styles.metaIcon} />
            <div>
              <div className={styles.metaLabel}>Order Date</div>
              <div className={styles.metaValue}>
                {new Date(order.created_at).toLocaleDateString("en-US", {
                  year: "numeric",
                  month: "long",
                  day: "numeric",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </div>
            </div>
          </div>

          <div className={styles.metaItem}>
            <DollarSign className={styles.metaIcon} />
            <div>
              <div className={styles.metaLabel}>Total Amount</div>
              <div className={styles.metaValue}>
                ${order.total_amount.toFixed(2)}
              </div>
            </div>
          </div>
        </div>

        <div className={styles.itemsSection}>
          <h2 className={styles.sectionTitle}>Order Items</h2>
          
          <div className={styles.itemsList}>
            {order.items && order.items.length > 0 ? (
              order.items.map((item) => (
                <div key={item.id} className={styles.item}>
                  <div className={styles.itemInfo}>
                    <div className={styles.itemName}>{item.product_name}</div>
                    <div className={styles.itemMeta}>
                      Quantity: {item.quantity} × ${item.price.toFixed(2)}
                    </div>
                  </div>
                  <div className={styles.itemPrice}>
                    ${item.subtotal.toFixed(2)}
                  </div>
                </div>
              ))
            ) : (
              <div className={styles.noItems}>No items in this order</div>
            )}
          </div>
        </div>

        <div className={styles.summarySection}>
          <div className={styles.summaryRow}>
            <span className={styles.summaryLabel}>Subtotal</span>
            <span className={styles.summaryValue}>
              ${order.total_amount.toFixed(2)}
            </span>
          </div>
          <div className={styles.summaryRow}>
            <span className={styles.summaryLabel}>Shipping</span>
            <span className={styles.summaryValue}>Free</span>
          </div>
          <div className={styles.summaryTotal}>
            <span className={styles.totalLabel}>Total</span>
            <span className={styles.totalValue}>
              ${order.total_amount.toFixed(2)}
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default OrderDetail;
