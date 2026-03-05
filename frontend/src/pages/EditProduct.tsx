import { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { productsApi } from "../api/products";
import type { UpdateProductData } from "../api/products";
import { categoriesApi } from "../api/categories";
import { ArrowLeft, Upload, X } from "lucide-react";
import styles from "./ProductForm.module.css";

interface Category {
  id: number;
  name: string;
}

const EditProduct = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(false);
  const [fetchingProduct, setFetchingProduct] = useState(true);
  const [error, setError] = useState("");
  const [imagePreviews, setImagePreviews] = useState<string[]>([]);

  const [formData, setFormData] = useState<UpdateProductData>({
    name: "",
    description: "",
    price: 0,
    stock: 0,
    category_id: 0,
    sku: "",
    active: true,
    images: [],
  });

  useEffect(() => {
    fetchCategories();
    if (id) {
      fetchProduct(id);
    }
  }, [id]);

  const fetchCategories = async () => {
    try {
      const categories = await categoriesApi.getAll();
      setCategories(categories);
    } catch (err) {
      console.error("Failed to fetch categories:", err);
    }
  };

  const fetchProduct = async (productId: string) => {
    try {
      const response = await productsApi.getById(productId);
      
      // Handle JSON:API response format
      const productData = response.data || response;
      const product = productData.attributes;
      const categoryId = productData.relationships?.category?.data?.id;
      
      setFormData({
        name: product.name,
        description: product.description,
        price: parseFloat(product.price),
        stock: product.stock,
        category_id: categoryId ? parseInt(categoryId) : 0,
        sku: product.sku,
        active: product.active,
      });
      
      if (product.image_urls && product.image_urls.length > 0) {
        setImagePreviews(product.image_urls);
      }
    } catch (err: any) {
      console.error("Fetch product error:", err);
      setError(err.response?.data?.error || "Failed to fetch product");
    } finally {
      setFetchingProduct(false);
    }
  };

  const handleImageChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files) return;

    const fileArray = Array.from(files);
    setFormData((prev) => ({ ...prev, images: fileArray }));

    const previews = fileArray.map((file) => URL.createObjectURL(file));
    setImagePreviews(previews);
  };

  const removeImage = (index: number) => {
    setFormData((prev) => ({
      ...prev,
      images: prev.images?.filter((_, i) => i !== index),
    }));
    setImagePreviews((prev) => prev.filter((_, i) => i !== index));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!id) return;
    
    setLoading(true);
    setError("");

    try {
      await productsApi.update(id, formData);
      navigate("/admin/products");
    } catch (err: any) {
      setError(err.response?.data?.errors?.join(", ") || "Failed to update product");
    } finally {
      setLoading(false);
    }
  };

  if (fetchingProduct) {
    return <div className={styles.container}>Loading product...</div>;
  }

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <button onClick={() => navigate("/admin/products")} className={styles.backButton}>
          <ArrowLeft size={20} />
          Back to Products
        </button>
        <h1 className={styles.title}>Edit Product</h1>
      </div>

      {error && <div className={styles.error}>{error}</div>}

      <form onSubmit={handleSubmit} className={styles.form}>
        <div className={styles.grid}>
          <div className={styles.formGroup}>
            <label htmlFor="name">Product Name *</label>
            <input
              id="name"
              type="text"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="Enter product name"
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="sku">SKU</label>
            <input
              id="sku"
              type="text"
              value={formData.sku}
              onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
              placeholder="Auto-generated if empty"
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="category">Category *</label>
            <select
              id="category"
              required
              value={formData.category_id}
              onChange={(e) =>
                setFormData({ ...formData, category_id: parseInt(e.target.value) })
              }
            >
              {categories.map((cat) => (
                <option key={cat.id} value={cat.id}>
                  {cat.name}
                </option>
              ))}
            </select>
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="price">Price *</label>
            <input
              id="price"
              type="number"
              required
              min="0"
              step="0.01"
              value={formData.price}
              onChange={(e) => setFormData({ ...formData, price: parseFloat(e.target.value) })}
              placeholder="0.00"
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="stock">Stock Quantity *</label>
            <input
              id="stock"
              type="number"
              required
              min="0"
              value={formData.stock}
              onChange={(e) => setFormData({ ...formData, stock: parseInt(e.target.value) })}
              placeholder="0"
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="active">Status</label>
            <select
              id="active"
              value={formData.active ? "true" : "false"}
              onChange={(e) => setFormData({ ...formData, active: e.target.value === "true" })}
            >
              <option value="true">Active</option>
              <option value="false">Inactive</option>
            </select>
          </div>
        </div>

        <div className={styles.formGroup}>
          <label htmlFor="description">Description *</label>
          <textarea
            id="description"
            required
            rows={5}
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Enter product description"
          />
        </div>

        <div className={styles.formGroup}>
          <label>Product Images</label>
          <div className={styles.imageUpload}>
            <input
              type="file"
              id="images"
              multiple
              accept="image/*"
              onChange={handleImageChange}
              className={styles.fileInput}
            />
            <label htmlFor="images" className={styles.uploadLabel}>
              <Upload size={24} />
              <span>Click to upload new images or drag and drop</span>
              <span className={styles.uploadHint}>PNG, JPG, GIF up to 10MB each</span>
            </label>
          </div>

          {imagePreviews.length > 0 && (
            <div className={styles.imagePreviews}>
              {imagePreviews.map((preview, index) => (
                <div key={index} className={styles.imagePreview}>
                  <img src={preview} alt={`Preview ${index + 1}`} />
                  <button
                    type="button"
                    onClick={() => removeImage(index)}
                    className={styles.removeImage}
                  >
                    <X size={16} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className={styles.actions}>
          <button
            type="button"
            onClick={() => navigate("/admin/products")}
            className={styles.cancelButton}
          >
            Cancel
          </button>
          <button type="submit" disabled={loading} className={styles.submitButton}>
            {loading ? "Updating..." : "Update Product"}
          </button>
        </div>
      </form>
    </div>
  );
};

export default EditProduct;
