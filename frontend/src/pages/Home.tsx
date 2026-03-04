import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { productsApi } from "../api/products";
import { ShoppingBag, Star, TrendingUp } from "lucide-react";
import styles from "./Home.module.css";
import type { Product } from "../types";

const Home = () => {
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchFeatured = async () => {
      try {
        const response = await productsApi.getFeatured(6);
        setFeaturedProducts(response.data);
      } catch (error) {
        console.error("Failed to fetch featured products:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchFeatured();
  }, []);

  return (
    <div>
      <section className={styles.hero}>
        <ShoppingBag className="w-20 h-20 text-primary-600 mx-auto mb-6" />
        <h1 className={styles.heroTitle}>
          Welcome to ShopHub
        </h1>
        <p className={styles.heroSubtitle}>
          Discover amazing products at unbeatable prices. Your one-stop shop for everything you need.
        </p>
        <div className="flex items-center justify-center space-x-4">
          <Link to="/products" className={styles.heroCta}>
            Browse Products
          </Link>
          <Link to="/products?featured=true" className="btn-secondary text-lg px-8 py-3">
            View Featured
          </Link>
        </div>
      </section>

      <section className={styles.productsSection}>
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center space-x-2">
            <TrendingUp className="w-6 h-6 text-primary-600" />
            <h2 className={styles.sectionTitle}>Featured Products</h2>
          </div>
          <Link to="/products?featured=true" className={styles.viewAllLink}>
            View All →
          </Link>
        </div>

        {loading ? (
          <div className={styles.productsGrid}>
            {[...Array(6)].map((_, i) => (
              <div key={i} className="card animate-pulse">
                <div className="bg-gray-300 h-48 rounded-lg mb-4"></div>
                <div className="h-4 bg-gray-300 rounded mb-2"></div>
                <div className="h-4 bg-gray-300 rounded w-2/3"></div>
              </div>
            ))}
          </div>
        ) : featuredProducts.length > 0 ? (
          <div className={styles.productsGrid}>
            {featuredProducts.map((product) => (
              <Link
                key={product.id}
                to={`/products/${product.id}`}
                className="card group cursor-pointer"
              >
                <div className="bg-gray-200 h-48 rounded-lg mb-4 flex items-center justify-center">
                  <ShoppingBag className="w-16 h-16 text-gray-400" />
                </div>
                <h3 className="text-xl font-semibold text-gray-900 mb-2 group-hover:text-primary-600 transition-colors">
                  {product.attributes.name}
                </h3>
                <p className="text-gray-600 text-sm mb-4 line-clamp-2">
                  {product.attributes.description}
                </p>
                <div className="flex items-center justify-between">
                  <span className="text-2xl font-bold text-primary-600">
                    ${parseFloat(product.attributes.price).toFixed(2)}
                  </span>
                  {product.attributes.average_rating > 0 && (
                    <div className="flex items-center space-x-1">
                      <Star className="w-4 h-4 text-yellow-500 fill-current" />
                      <span className="text-sm text-gray-600">
                        {product.attributes.average_rating.toFixed(1)}
                      </span>
                    </div>
                  )}
                </div>
                {product.attributes.in_stock ? (
                  <span className="inline-block mt-3 text-xs text-green-600 bg-green-50 px-3 py-1 rounded-full">
                    In Stock
                  </span>
                ) : (
                  <span className="inline-block mt-3 text-xs text-red-600 bg-red-50 px-3 py-1 rounded-full">
                    Out of Stock
                  </span>
                )}
              </Link>
            ))}
          </div>
        ) : (
          <div className="text-center py-12 text-gray-500">
            No featured products available
          </div>
        )}
      </section>

      <section className={styles.featuresSection}>
        <div className={styles.featuresGrid}>
          <div className={styles.featureCard}>
            <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <ShoppingBag className={styles.featureIcon} />
            </div>
            <h3 className={styles.featureTitle}>Wide Selection</h3>
            <p className={styles.featureDescription}>Thousands of products across multiple categories</p>
          </div>
          
          <div className={styles.featureCard}>
            <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <Star className={styles.featureIcon} />
            </div>
            <h3 className={styles.featureTitle}>Top Quality</h3>
            <p className={styles.featureDescription}>Only the best products with verified reviews</p>
          </div>
          
          <div className={styles.featureCard}>
            <div className="bg-primary-100 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-4">
              <TrendingUp className={styles.featureIcon} />
            </div>
            <h3 className={styles.featureTitle}>Best Prices</h3>
            <p className={styles.featureDescription}>Competitive pricing on all products</p>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
