import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { cartApi } from "../api/cart";
import { useCartStore } from "../store/cartStore";
import { ShoppingBag, Trash2, Plus, Minus } from "lucide-react";
import styles from "./Cart.module.css";

const Cart = () => {
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const { items, total, setCart } = useCartStore();
  const navigate = useNavigate();

  useEffect(() => {
    fetchCart();
  }, []);

  const fetchCart = async () => {
    try {
      const response = await cartApi.getItems();
      setCart(response.cart_items || [], response.total || 0);
    } catch (error) {
      console.error("Failed to fetch cart:", error);
      setCart([], 0);
    } finally {
      setLoading(false);
    }
  };

  const updateQuantity = async (productId: number, newQuantity: number) => {
    if (newQuantity < 1) return;
    
    setUpdating(true);
    try {
      const response = await cartApi.updateQuantity(productId, newQuantity);
      setCart(response.cart_items || [], response.total || 0);
    } catch (error) {
      console.error("Failed to update quantity:", error);
      await fetchCart();
    } finally {
      setUpdating(false);
    }
  };

  const removeItem = async (productId: number) => {
    setUpdating(true);
    try {
      const response = await cartApi.removeItem(productId);
      setCart(response.cart_items || [], response.total || 0);
    } catch (error) {
      console.error("Failed to remove item:", error);
      await fetchCart();
    } finally {
      setUpdating(false);
    }
  };

  const handleCheckout = () => {
    navigate("/checkout");
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.loadingTitle}></div>
          <div className={styles.loadingItems}>
            {[...Array(3)].map((_, i) => (
              <div key={i} className={styles.loadingItem}></div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (!items || items.length === 0) {
    return (
      <div className={styles.emptyState}>
        <ShoppingBag className={styles.emptyIcon} />
        <h2 className={styles.emptyTitle}>Your cart is empty</h2>
        <p className={styles.emptyMessage}>Start shopping to add items to your cart</p>
        <Link to="/products" className={styles.emptyButton}>
          Browse Products
        </Link>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <h1 className={styles.title}>Shopping Cart</h1>

      <div className={styles.grid}>
        <div className={styles.itemsColumn}>
          {items.map((item) => (
            <div key={item.product_id} className={styles.itemCard}>
              <div className={styles.itemImage}>
                <ShoppingBag className={styles.itemImageIcon} />
              </div>

              <div className={styles.itemInfo}>
                <h3 className={styles.itemName}>{item.name}</h3>
                <p className={styles.itemPrice}>${item.price.toFixed(2)} each</p>
                <p className={styles.itemStock}>Stock: {item.stock}</p>
              </div>

              <div className={styles.quantityControls}>
                <button
                  onClick={() => updateQuantity(item.product_id, item.quantity - 1)}
                  disabled={updating || item.quantity <= 1}
                  className={styles.quantityButton}
                >
                  <Minus className={styles.quantityIcon} />
                </button>
                
                <span className={styles.quantityText}>{item.quantity}</span>
                
                <button
                  onClick={() => updateQuantity(item.product_id, item.quantity + 1)}
                  disabled={updating || item.quantity >= item.stock}
                  className={styles.quantityButton}
                >
                  <Plus className={styles.quantityIcon} />
                </button>
              </div>

              <div className={styles.itemRight}>
                <p className={styles.itemSubtotal}>
                  ${item.subtotal.toFixed(2)}
                </p>
                <button
                  onClick={() => removeItem(item.product_id)}
                  disabled={updating}
                  className={styles.removeButton}
                >
                  <Trash2 className={styles.removeIcon} />
                  <span>Remove</span>
                </button>
              </div>
            </div>
          ))}
        </div>

        <div className={styles.summaryColumn}>
          <div className={styles.summaryCard}>
            <h2 className={styles.summaryTitle}>Order Summary</h2>
            
            <div className={styles.summaryContent}>
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
            </div>

            <button
              onClick={handleCheckout}
              className={styles.checkoutButton}
            >
              Proceed to Checkout
            </button>

            <button
              onClick={() => navigate("/products")}
              className={styles.continueButton}
            >
              Continue Shopping
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Cart;
