import { useEffect, useState } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { productsApi } from "../api/products";
import { cartApi } from "../api/cart";
import { useAuthStore } from "../store/authStore";
import { useCartStore } from "../store/cartStore";
import { ShoppingCart, Star, Package, AlertCircle } from "lucide-react";
import styles from "./ProductDetail.module.css";
import type { Product } from "../types";

const ProductDetail = () => {
  const { id } = useParams<{ id: string }>();
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [quantity, setQuantity] = useState(1);
  const [addingToCart, setAddingToCart] = useState(false);
  const [message, setMessage] = useState("");
  const { isAuthenticated } = useAuthStore();
  const { setCart } = useCartStore();
  const navigate = useNavigate();

  useEffect(() => {
    if (id) {
      fetchProduct();
    }
  }, [id]);

  const fetchProduct = async () => {
    try {
      const response = await productsApi.getById(id!);
      setProduct(response.data);
    } catch (error) {
      console.error("Failed to fetch product:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = async () => {
    if (!isAuthenticated) {
      navigate("/login");
      return;
    }

    setAddingToCart(true);
    setMessage("");

    try {
      const response = await cartApi.addItem(Number(id), quantity);
      setCart(response.cart_items, response.total);
      setMessage("Added to cart successfully!");
      setTimeout(() => setMessage(""), 3000);
    } catch (error: any) {
      setMessage(error.response?.data?.error || "Failed to add to cart");
    } finally {
      setAddingToCart(false);
    }
  };

  if (loading) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingCard}>
          <div className={styles.grid}>
            <div className="bg-gray-300 h-96 rounded-lg"></div>
            <div className="space-y-4">
              <div className={styles.loadingSkeleton}></div>
              <div className={`${styles.loadingSkeleton} w-3/4`}></div>
              <div className={`${styles.loadingSkeleton} w-1/2`}></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!product) {
    return (
      <div className={styles.notFoundContainer}>
        <Package className={styles.notFoundIcon} />
        <h2 className={styles.notFoundTitle}>Product Not Found</h2>
        <Link to="/products" className={styles.notFoundLink}>
          Browse all products →
        </Link>
      </div>
    );
  }

  const { attributes } = product;

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.grid}>
          <div className={styles.imageSection}>
            {attributes.image_urls.length > 0 ? (
              <img
                src={attributes.image_urls[0]}
                alt={attributes.name}
                className={styles.productImage}
              />
            ) : (
              <Package className={styles.imagePlaceholder} />
            )}
          </div>

          <div className={styles.infoSection}>
            <div className={styles.titleSection}>
              <h1 className={styles.title}>
                {attributes.name}
              </h1>
              
              {attributes.average_rating > 0 && (
                <div className={styles.ratingSection}>
                  <div className={styles.stars}>
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`${styles.star} ${
                          i < Math.round(attributes.average_rating)
                            ? styles.starFilled
                            : styles.starEmpty
                        }`}
                      />
                    ))}
                  </div>
                  <span className={styles.ratingText}>
                    {attributes.average_rating.toFixed(1)} rating
                  </span>
                </div>
              )}
              
              <p className={styles.description}>
                {attributes.description}
              </p>
            </div>

            <div className={styles.priceSection}>
              <div className={styles.priceRow}>
                <span className={styles.price}>
                  ${parseFloat(attributes.price).toFixed(2)}
                </span>
                <span className={styles.sku}>SKU: {attributes.sku}</span>
              </div>
            </div>

            <div className={styles.purchaseSection}>
              {attributes.in_stock ? (
                <>
                  <div className={styles.stockInfo}>
                    <AlertCircle className="w-5 h-5 text-green-600" />
                    <span className="font-medium text-green-600">{attributes.stock} in stock</span>
                  </div>

                  <div className={styles.quantityRow}>
                    <label className={styles.quantityLabel}>Quantity:</label>
                    <select
                      value={quantity}
                      onChange={(e) => setQuantity(Number(e.target.value))}
                      className={styles.quantitySelect}
                    >
                      {[...Array(Math.min(attributes.stock, 10))].map((_, i) => (
                        <option key={i + 1} value={i + 1}>
                          {i + 1}
                        </option>
                      ))}
                    </select>
                  </div>

                  <button
                    onClick={handleAddToCart}
                    disabled={addingToCart}
                    className={styles.addToCartButton}
                  >
                    <ShoppingCart className={styles.addToCartIcon} />
                    <span>{addingToCart ? "Adding..." : "Add to Cart"}</span>
                  </button>

                  {message && (
                    <div
                      className={`${styles.message} ${
                        message.includes("success")
                          ? styles.messageSuccess
                          : styles.messageError
                      }`}
                    >
                      {message}
                    </div>
                  )}
                </>
              ) : (
                <div className={styles.outOfStockCard}>
                  <p className={styles.outOfStockText}>Out of Stock</p>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ProductDetail;
