import { useState, useEffect } from "react";
import { Link, useNavigate } from "react-router-dom";
import { productsApi } from "../api/products";
import { Plus, Edit, Trash2, Package } from "lucide-react";
import styles from "./AdminProducts.module.css";

interface ProductListItem {
  id: string;
  name: string;
  description: string;
  price: number;
  stock: number;
  sku: string;
  active: boolean;
  category?: {
    id: string;
    name: string;
  };
}

const AdminProducts = () => {
  const navigate = useNavigate();
  const [products, setProducts] = useState<ProductListItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const response = await productsApi.getAll({ per_page: 100 });
      
      // Extract categories from included data
      const included = (response as any).included || [];
      const categoriesMap = new Map<string, string>(
        included
          .filter((item: any) => item.type === "category")
          .map((cat: any) => [cat.id, cat.attributes.name as string])
      );
      
      const productList: ProductListItem[] = response.data.map((p) => {
        const categoryId = p.relationships?.category?.data?.id;
        const categoryName = categoryId ? categoriesMap.get(categoryId) : undefined;
        
        return {
          id: p.id,
          name: p.attributes.name,
          description: p.attributes.description,
          price: parseFloat(p.attributes.price),
          stock: p.attributes.stock,
          sku: p.attributes.sku,
          active: p.attributes.active,
          category: categoryId && categoryName ? {
            id: categoryId,
            name: categoryName
          } : undefined
        };
      });
      setProducts(productList);
    } catch (err: any) {
      setError(err.response?.data?.error || "Failed to fetch products");
    } finally {
      setLoading(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this product?")) return;

    try {
      await productsApi.delete(id);
      setProducts(products.filter((p) => p.id !== id));
    } catch (err: any) {
      alert(err.response?.data?.error || "Failed to delete product");
    }
  };

  if (loading) {
    return <div className={styles.loading}>Loading products...</div>;
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Product Management</h1>
          <p className={styles.subtitle}>Manage your product catalog</p>
        </div>
        <Link to="/admin/products/new" className={styles.createButton}>
          <Plus size={20} />
          Add New Product
        </Link>
      </div>

      {error && (
        <div className={styles.error}>
          {error}
        </div>
      )}

      <div className={styles.tableContainer}>
        <table className={styles.table}>
          <thead>
            <tr>
              <th>SKU</th>
              <th>Name</th>
              <th>Category</th>
              <th>Price</th>
              <th>Stock</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {products.length === 0 ? (
              <tr>
                <td colSpan={7} className={styles.emptyState}>
                  <Package size={48} />
                  <p>No products found</p>
                  <Link to="/admin/products/new">Create your first product</Link>
                </td>
              </tr>
            ) : (
              products.map((product) => (
                <tr 
                  key={product.id}
                  className={styles.tableRow}
                  onClick={() => navigate(`/admin/products/${product.id}/edit`)}
                  title="Click row to edit product"
                >
                  <td className={styles.sku}>{product.sku}</td>
                  <td>
                    <div className={styles.productName}>{product.name}</div>
                    <div className={styles.productDesc}>
                      {product.description?.substring(0, 60)}...
                    </div>
                  </td>
                  <td>{product.category?.name || "-"}</td>
                  <td className={styles.price}>${product.price.toFixed(2)}</td>
                  <td>
                    <span
                      className={`${styles.stock} ${
                        product.stock > 0 ? styles.inStock : styles.outOfStock
                      }`}
                    >
                      {product.stock}
                    </span>
                  </td>
                  <td>
                    <span
                      className={`${styles.status} ${
                        product.active ? styles.active : styles.inactive
                      }`}
                    >
                      {product.active ? "Active" : "Inactive"}
                    </span>
                  </td>
                  <td onClick={(e) => e.stopPropagation()}>
                    <div className={styles.actions}>
                      <Link
                        to={`/admin/products/${product.id}/edit`}
                        className={styles.editButton}
                        title="Edit"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <Edit size={16} />
                      </Link>
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          handleDelete(product.id);
                        }}
                        className={styles.deleteButton}
                        title="Delete"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default AdminProducts;
