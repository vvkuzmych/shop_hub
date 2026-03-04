import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { ordersApi } from "../api/orders";
import { Package, Calendar, DollarSign, XCircle } from "lucide-react";
import styles from "./Orders.module.css";
import type { Order } from "../types";

const Orders = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [cancelingId, setCancelingId] = useState<string | null>(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await ordersApi.getAll();
      setOrders(response.data);
    } catch (error) {
      console.error("Failed to fetch orders:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async (orderId: string) => {
    if (!confirm("Are you sure you want to cancel this order?")) {
      return;
    }

    setCancelingId(orderId);
    try {
      await ordersApi.cancel(orderId);
      fetchOrders();
    } catch (error: any) {
      alert(error.response?.data?.error || "Failed to cancel order");
    } finally {
      setCancelingId(null);
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


  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        {[...Array(3)].map((_, i) => (
          <div key={i} className={styles.loadingCard}>
            <div className={styles.loadingTitle}></div>
            <div className={styles.loadingMeta}></div>
          </div>
        ))}
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <div className={styles.emptyState}>
        <Package className={styles.emptyIcon} />
        <h2 className={styles.emptyTitle}>No orders yet</h2>
        <p className={styles.emptyMessage}>Start shopping to place your first order</p>
        <Link to="/products" className={styles.emptyButton}>
          Browse Products
        </Link>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>My Orders</h1>

      <div className={styles.ordersList}>
        {orders.map((order) => (
          <div key={order.id} className={styles.orderCard}>
            <div className={styles.orderHeader}>
              <div className={styles.orderInfo}>
                <div className={styles.orderTitleRow}>
                  <h3 className={styles.orderTitle}>
                    Order #{order.id}
                  </h3>
                  <span
                    className={`${styles.statusBadge} ${getStatusClass(order.attributes.status)}`}
                  >
                    {order.attributes.status.toUpperCase()}
                  </span>
                </div>
                
                <div className={styles.orderMeta}>
                  <div className={styles.metaItem}>
                    <Calendar className={styles.metaIcon} />
                    <span>
                      {new Date(order.attributes.created_at).toLocaleDateString()}
                    </span>
                  </div>
                  <div className={styles.metaItem}>
                    <DollarSign className={styles.metaIcon} />
                    <span>${parseFloat(order.attributes.total_amount).toFixed(2)}</span>
                  </div>
                </div>
              </div>

              <div className={styles.orderActions}>
                <Link
                  to={`/orders/${order.id}`}
                  className={styles.viewDetailsButton}
                >
                  View Details
                </Link>
                
                {order.attributes.status === "pending" && (
                  <button
                    onClick={() => handleCancel(order.id)}
                    disabled={cancelingId === order.id}
                    className={styles.cancelButton}
                  >
                    <XCircle className={styles.cancelIcon} />
                    <span>{cancelingId === order.id ? "Canceling..." : "Cancel"}</span>
                  </button>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Orders;
