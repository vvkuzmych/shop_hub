import { useEffect, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { productsApi } from "../api/products";
import { Search, Filter, ShoppingBag, Star } from "lucide-react";
import styles from "./Products.module.css";
import type { Product } from "../types";

const Products = () => {
  const [searchParams, setSearchParams] = useSearchParams();
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState(searchParams.get("q") || "");
  const [minPrice, setMinPrice] = useState("");
  const [maxPrice, setMaxPrice] = useState("");
  const [inStockOnly, setInStockOnly] = useState(false);

  useEffect(() => {
    fetchProducts();
  }, [searchParams]);

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const filters = {
        q: searchParams.get("q") || undefined,
        min_price: searchParams.get("min_price") ? Number(searchParams.get("min_price")) : undefined,
        max_price: searchParams.get("max_price") ? Number(searchParams.get("max_price")) : undefined,
        in_stock: searchParams.get("in_stock") === "true" || undefined,
        featured: searchParams.get("featured") === "true" || undefined,
      };
      
      const response = await productsApi.getAll(filters);
      setProducts(response.data);
    } catch (error) {
      console.error("Failed to fetch products:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    const newParams = new URLSearchParams(searchParams);
    
    if (searchQuery) {
      newParams.set("q", searchQuery);
    } else {
      newParams.delete("q");
    }
    
    setSearchParams(newParams);
  };

  const handleApplyFilters = () => {
    const newParams = new URLSearchParams(searchParams);
    
    if (minPrice) newParams.set("min_price", minPrice);
    else newParams.delete("min_price");
    
    if (maxPrice) newParams.set("max_price", maxPrice);
    else newParams.delete("max_price");
    
    if (inStockOnly) newParams.set("in_stock", "true");
    else newParams.delete("in_stock");
    
    setSearchParams(newParams);
  };

  const clearFilters = () => {
    setSearchQuery("");
    setMinPrice("");
    setMaxPrice("");
    setInStockOnly(false);
    setSearchParams({});
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Products</h1>
        <span className="text-gray-600">{products.length} products found</span>
      </div>

      <div className={styles.filtersCard}>
        <form onSubmit={handleSearch} className={styles.searchBar}>
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search products..."
              className={styles.searchInput}
            />
          </div>
          <button type="submit" className={styles.searchButton}>
            Search
          </button>
        </form>

        <div className={styles.filtersTitle}>
          <Filter className="w-5 h-5" />
          <span>Filters:</span>
        </div>
        
        <div className={styles.filtersGrid}>
          <div className={styles.filterGroup}>
            <label className={styles.filterLabel}>Min Price</label>
            <input
              type="number"
              value={minPrice}
              onChange={(e) => setMinPrice(e.target.value)}
              placeholder="Min $"
              className={styles.filterSelect}
            />
          </div>
          
          <div className={styles.filterGroup}>
            <label className={styles.filterLabel}>Max Price</label>
            <input
              type="number"
              value={maxPrice}
              onChange={(e) => setMaxPrice(e.target.value)}
              placeholder="Max $"
              className={styles.filterSelect}
            />
          </div>
          
          <label className={styles.checkboxLabel}>
            <input
              type="checkbox"
              checked={inStockOnly}
              onChange={(e) => setInStockOnly(e.target.checked)}
              className={styles.checkbox}
            />
            <span className={styles.checkboxText}>In Stock Only</span>
          </label>
          
          <button onClick={handleApplyFilters} className={styles.applyButton}>
            Apply
          </button>
          
          <button onClick={clearFilters} className={styles.clearButton}>
            Clear
          </button>
        </div>
      </div>

      {loading ? (
        <div className={styles.productsGrid}>
          {[...Array(8)].map((_, i) => (
            <div key={i} className={styles.loadingCard}>
              <div className={styles.loadingImage}></div>
              <div className={styles.loadingSkeleton}></div>
              <div className={`${styles.loadingSkeleton} w-2/3`}></div>
            </div>
          ))}
        </div>
      ) : products.length > 0 ? (
        <div className={styles.productsGrid}>
          {products.map((product) => (
            <Link
              key={product.id}
              to={`/products/${product.id}`}
              className={styles.productCard}
            >
              <div className={styles.productImage}>
                {product.attributes.image_urls.length > 0 ? (
                  <img
                    src={product.attributes.image_urls[0]}
                    alt={product.attributes.name}
                    className={styles.productImageElement}
                  />
                ) : (
                  <ShoppingBag className={styles.productImagePlaceholder} />
                )}
              </div>
              
              <h3 className={styles.productTitle}>
                {product.attributes.name}
              </h3>
              
              <p className={styles.productDescription}>
                {product.attributes.description}
              </p>
              
              <div className={styles.productPriceRow}>
                <span className={styles.productPrice}>
                  ${parseFloat(product.attributes.price).toFixed(2)}
                </span>
                {product.attributes.average_rating > 0 && (
                  <div className={styles.productRating}>
                    <Star className={styles.ratingIcon} />
                    <span className={styles.ratingText}>
                      {product.attributes.average_rating.toFixed(1)}
                    </span>
                  </div>
                )}
              </div>
              
              <div className={styles.productBadgeRow}>
                {product.attributes.in_stock ? (
                  <span className={styles.inStockBadge}>
                    {product.attributes.stock} in stock
                  </span>
                ) : (
                  <span className={styles.outOfStockBadge}>
                    Out of Stock
                  </span>
                )}
                
                {product.attributes.featured && (
                  <span className={styles.featuredBadge}>
                    Featured
                  </span>
                )}
              </div>
            </Link>
          ))}
        </div>
      ) : (
        <div className={styles.emptyState}>
          <ShoppingBag className={styles.emptyIcon} />
          <h3 className={styles.emptyTitle}>No products found</h3>
          <p className={styles.emptyMessage}>Try adjusting your search or filters</p>
          <button onClick={clearFilters} className={styles.emptyButton}>
            Clear Filters
          </button>
        </div>
      )}
    </div>
  );
};

export default Products;
