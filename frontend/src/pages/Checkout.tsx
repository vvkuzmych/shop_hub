import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { cartApi } from "../api/cart";
import { ordersApi } from "../api/orders";
import { Package, MapPin, Store, CreditCard } from "lucide-react";
import styles from "./Checkout.module.css";
import { useCartStore } from "../store/cartStore";

const Checkout = () => {
  const navigate = useNavigate();
  const { items, total, clearCart: clearCartStore } = useCartStore();
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [deliveryMethod, setDeliveryMethod] = useState<"delivery" | "pickup">("delivery");
  const [deliveryAddress, setDeliveryAddress] = useState({
    street: "",
    city: "",
    state: "",
    zipCode: "",
    country: ""
  });
  const [notes, setNotes] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    fetchCart();
  }, []);

  const fetchCart = async () => {
    try {
      await cartApi.getItems();
      setLoading(false);
    } catch (error) {
      console.error("Failed to fetch cart:", error);
      setLoading(false);
    }
  };

  const handleAddressChange = (field: string, value: string) => {
    setDeliveryAddress(prev => ({ ...prev, [field]: value }));
  };

  const formatAddress = () => {
    return `${deliveryAddress.street}\n${deliveryAddress.city}, ${deliveryAddress.state} ${deliveryAddress.zipCode}\n${deliveryAddress.country}`;
  };

  const handlePlaceOrder = async () => {
    setError("");
    
    if (deliveryMethod === "delivery") {
      if (!deliveryAddress.street || !deliveryAddress.city || !deliveryAddress.state || !deliveryAddress.zipCode) {
        setError("Please fill in all delivery address fields");
        return;
      }
    }

    setProcessing(true);
    
    try {
      const orderData = {
        items: items.map(item => ({
          product_id: item.product_id,
          quantity: item.quantity
        })),
        delivery_method: deliveryMethod,
        delivery_address: deliveryMethod === "delivery" ? formatAddress() : undefined,
        notes: notes
      };

      const response = await ordersApi.create(orderData);
      const orderId = response.data.id;
      
      clearCartStore();
      
      // Redirect to payment page
      navigate(`/orders/${orderId}/payment`);
    } catch (err: any) {
      setError(err.response?.data?.errors?.join(", ") || "Failed to create order");
      setProcessing(false);
    }
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.loadingSkeleton}></div>
        </div>
      </div>
    );
  }

  if (items.length === 0) {
    return (
      <div className={styles.emptyState}>
        <Package className={styles.emptyIcon} />
        <h2 className={styles.emptyTitle}>Your cart is empty</h2>
        <p className={styles.emptyMessage}>Add items to your cart before checking out</p>
        <button onClick={() => navigate("/products")} className={styles.emptyButton}>
          Browse Products
        </button>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Checkout</h1>

      <div className={styles.grid}>
        <div className={styles.mainColumn}>
          {/* Delivery Method */}
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>Delivery Method</h2>
            
            <div className={styles.deliveryOptions}>
              <button
                className={`${styles.deliveryOption} ${deliveryMethod === "delivery" ? styles.deliveryOptionActive : ""}`}
                onClick={() => setDeliveryMethod("delivery")}
              >
                <MapPin className={styles.deliveryIcon} />
                <div>
                  <div className={styles.deliveryOptionTitle}>Home Delivery</div>
                  <div className={styles.deliveryOptionDesc}>Delivered to your address</div>
                </div>
              </button>
              
              <button
                className={`${styles.deliveryOption} ${deliveryMethod === "pickup" ? styles.deliveryOptionActive : ""}`}
                onClick={() => setDeliveryMethod("pickup")}
              >
                <Store className={styles.deliveryIcon} />
                <div>
                  <div className={styles.deliveryOptionTitle}>Store Pickup</div>
                  <div className={styles.deliveryOptionDesc}>Pick up from our store</div>
                </div>
              </button>
            </div>
          </div>

          {/* Delivery Address */}
          {deliveryMethod === "delivery" && (
            <div className={styles.section}>
              <h2 className={styles.sectionTitle}>Delivery Address</h2>
              
              <div className={styles.form}>
                <div className={styles.formGroup}>
                  <label className={styles.label}>Street Address</label>
                  <input
                    type="text"
                    value={deliveryAddress.street}
                    onChange={(e) => handleAddressChange("street", e.target.value)}
                    className={styles.input}
                    placeholder="123 Main St"
                  />
                </div>
                
                <div className={styles.formGrid}>
                  <div className={styles.formGroup}>
                    <label className={styles.label}>City</label>
                    <input
                      type="text"
                      value={deliveryAddress.city}
                      onChange={(e) => handleAddressChange("city", e.target.value)}
                      className={styles.input}
                      placeholder="New York"
                    />
                  </div>
                  
                  <div className={styles.formGroup}>
                    <label className={styles.label}>State</label>
                    <input
                      type="text"
                      value={deliveryAddress.state}
                      onChange={(e) => handleAddressChange("state", e.target.value)}
                      className={styles.input}
                      placeholder="NY"
                    />
                  </div>
                </div>
                
                <div className={styles.formGrid}>
                  <div className={styles.formGroup}>
                    <label className={styles.label}>ZIP Code</label>
                    <input
                      type="text"
                      value={deliveryAddress.zipCode}
                      onChange={(e) => handleAddressChange("zipCode", e.target.value)}
                      className={styles.input}
                      placeholder="10001"
                    />
                  </div>
                  
                  <div className={styles.formGroup}>
                    <label className={styles.label}>Country</label>
                    <input
                      type="text"
                      value={deliveryAddress.country}
                      onChange={(e) => handleAddressChange("country", e.target.value)}
                      className={styles.input}
                      placeholder="USA"
                    />
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* Order Notes */}
          <div className={styles.section}>
            <h2 className={styles.sectionTitle}>Order Notes (Optional)</h2>
            <textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              className={styles.textarea}
              placeholder="Any special instructions for your order..."
              rows={3}
            />
          </div>
        </div>

        {/* Order Summary */}
        <div className={styles.summaryColumn}>
          <div className={styles.summaryCard}>
            <h2 className={styles.summaryTitle}>Order Summary</h2>
            
            <div className={styles.summaryItems}>
              {items.map((item) => (
                <div key={item.product_id} className={styles.summaryItem}>
                  <span className={styles.summaryItemName}>
                    {item.name} × {item.quantity}
                  </span>
                  <span className={styles.summaryItemPrice}>
                    ${item.subtotal.toFixed(2)}
                  </span>
                </div>
              ))}
            </div>
            
            <div className={styles.summaryDivider}></div>
            
            <div className={styles.summaryRow}>
              <span>Subtotal</span>
              <span>${total.toFixed(2)}</span>
            </div>
            <div className={styles.summaryRow}>
              <span>Shipping</span>
              <span>Free</span>
            </div>
            
            <div className={styles.summaryTotal}>
              <span>Total</span>
              <span>${total.toFixed(2)}</span>
            </div>
            
            {error && (
              <div className={styles.error}>{error}</div>
            )}
            
            <button
              onClick={handlePlaceOrder}
              disabled={processing}
              className={styles.checkoutButton}
            >
              <CreditCard className="w-5 h-5" />
              <span>{processing ? "Processing..." : "Proceed to Payment"}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Checkout;
