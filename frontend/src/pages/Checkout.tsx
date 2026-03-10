import { useState, useEffect, useCallback } from "react";
import { useNavigate } from "react-router-dom";
import { cartApi } from "../api/cart";
import { ordersApi } from "../api/orders";
import { novaPoshtaApi } from "../api/novaPoshta";
import type { NovaPoshtaCity, NovaPoshtaWarehouse, NovaPoshtaPostomat } from "../api/novaPoshta";
import { Package, MapPin, Store, CreditCard, Truck } from "lucide-react";
import styles from "./Checkout.module.css";
import { useCartStore } from "../store/cartStore";
import DeliveryMapSimple from "../components/DeliveryMapSimple";

const Checkout = () => {
  const navigate = useNavigate();
  const { items, total, clearCart: clearCartStore } = useCartStore();
  const [loading, setLoading] = useState(true);
  const [processing, setProcessing] = useState(false);
  const [deliveryMethod, setDeliveryMethod] = useState<"delivery" | "pickup" | "nova_poshta">("delivery");
  const [deliveryAddress, setDeliveryAddress] = useState({
    street: "",
    city: "",
    state: "",
    zipCode: "",
    country: ""
  });
  const [novaPoshtaData, setNovaPoshtaData] = useState({
    cityQuery: "",
    selectedCity: null as NovaPoshtaCity | null,
    deliveryType: "warehouse" as "warehouse" | "postomat",
    selectedWarehouse: null as (NovaPoshtaWarehouse | NovaPoshtaPostomat) | null,
    recipientPhone: ""
  });
  const [citySuggestions, setCitySuggestions] = useState<NovaPoshtaCity[]>([]);
  const [warehouseSuggestions, setWarehouseSuggestions] = useState<(NovaPoshtaWarehouse | NovaPoshtaPostomat)[]>([]);
  const [loadingCities, setLoadingCities] = useState(false);
  const [loadingWarehouses, setLoadingWarehouses] = useState(false);
  const [showCityDropdown, setShowCityDropdown] = useState(false);
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

  // Debounced city search
  const searchCities = useCallback(async (query: string) => {
    if (query.length < 2) {
      setCitySuggestions([]);
      return;
    }

    setLoadingCities(true);
    try {
      const cities = await novaPoshtaApi.searchCities(query);
      setCitySuggestions(cities);
      setShowCityDropdown(true);
    } catch (error) {
      console.error("Failed to search cities:", error);
    } finally {
      setLoadingCities(false);
    }
  }, []);

  // Load warehouses/postomats when city is selected
  useEffect(() => {
    const loadWarehouses = async () => {
      if (!novaPoshtaData.selectedCity) {
        setWarehouseSuggestions([]);
        return;
      }

      setLoadingWarehouses(true);
      try {
        let warehouses;
        if (novaPoshtaData.deliveryType === "postomat") {
          warehouses = await novaPoshtaApi.getPostomats(novaPoshtaData.selectedCity.ref);
        } else {
          warehouses = await novaPoshtaApi.getWarehouses(novaPoshtaData.selectedCity.ref);
        }
        setWarehouseSuggestions(warehouses);
      } catch (error) {
        console.error("Failed to load warehouses:", error);
      } finally {
        setLoadingWarehouses(false);
      }
    };

    loadWarehouses();
  }, [novaPoshtaData.selectedCity, novaPoshtaData.deliveryType]);

  const formatAddress = () => {
    if (deliveryMethod === "nova_poshta") {
      const cityName = novaPoshtaData.selectedCity?.name || "";
      const warehouseDesc = novaPoshtaData.selectedWarehouse?.description || "";
      const phone = novaPoshtaData.recipientPhone;
      const type = novaPoshtaData.deliveryType === "postomat" ? "Поштомат" : "Відділення";
      return `Nova Poshta\nТип: ${type}\nМісто: ${cityName}\n${warehouseDesc}\nТелефон: ${phone}`;
    }
    return `${deliveryAddress.street}\n${deliveryAddress.city}, ${deliveryAddress.state} ${deliveryAddress.zipCode}\n${deliveryAddress.country}`;
  };

  const handlePlaceOrder = async () => {
    setError("");
    
    if (deliveryMethod === "delivery") {
      if (!deliveryAddress.street || !deliveryAddress.city || !deliveryAddress.state || !deliveryAddress.zipCode) {
        setError("Please fill in all delivery address fields");
        return;
      }
    } else if (deliveryMethod === "nova_poshta") {
      if (!novaPoshtaData.selectedCity || !novaPoshtaData.selectedWarehouse || !novaPoshtaData.recipientPhone) {
        setError("Будь ласка, заповніть всі поля доставки Нової Пошти");
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
        delivery_address: (deliveryMethod === "delivery" || deliveryMethod === "nova_poshta") ? formatAddress() : undefined,
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
              
              <button
                className={`${styles.deliveryOption} ${deliveryMethod === "nova_poshta" ? styles.deliveryOptionActive : ""}`}
                onClick={() => setDeliveryMethod("nova_poshta")}
              >
                <Truck className={styles.deliveryIcon} />
                <div>
                  <div className={styles.deliveryOptionTitle}>Nova Poshta</div>
                  <div className={styles.deliveryOptionDesc}>Delivery to Nova Poshta warehouse</div>
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

          {/* Nova Poshta Delivery */}
          {deliveryMethod === "nova_poshta" && (
            <div className={styles.section}>
              <h2 className={styles.sectionTitle}>Доставка Новою Поштою</h2>
              
              <div className={styles.form}>
                {/* Delivery Type Selection */}
                <div className={styles.formGroup}>
                  <label className={styles.label}>Тип доставки</label>
                  <div className={styles.deliveryTypeButtons}>
                    <button
                      type="button"
                      className={`${styles.deliveryTypeBtn} ${novaPoshtaData.deliveryType === "warehouse" ? styles.deliveryTypeBtnActive : ""}`}
                      onClick={() => {
                        setNovaPoshtaData(prev => ({ 
                          ...prev, 
                          deliveryType: "warehouse",
                          selectedWarehouse: null
                        }));
                      }}
                    >
                      <Store size={20} />
                      Відділення
                    </button>
                    <button
                      type="button"
                      className={`${styles.deliveryTypeBtn} ${novaPoshtaData.deliveryType === "postomat" ? styles.deliveryTypeBtnActive : ""}`}
                      onClick={() => {
                        setNovaPoshtaData(prev => ({ 
                          ...prev, 
                          deliveryType: "postomat",
                          selectedWarehouse: null
                        }));
                      }}
                    >
                      <Package size={20} />
                      Поштомат
                    </button>
                  </div>
                </div>

                {/* City Autocomplete */}
                <div className={styles.formGroup}>
                  <label className={styles.label}>Місто</label>
                  <div className={styles.autocompleteWrapper}>
                    <input
                      type="text"
                      value={novaPoshtaData.cityQuery}
                      onChange={(e) => {
                        const query = e.target.value;
                        setNovaPoshtaData(prev => ({ ...prev, cityQuery: query, selectedCity: null }));
                        searchCities(query);
                      }}
                      onFocus={() => {
                        if (citySuggestions.length > 0) {
                          setShowCityDropdown(true);
                        }
                      }}
                      className={styles.input}
                      placeholder="Введіть назву міста (наприклад, Київ, Львів, Одеса)"
                      autoComplete="off"
                    />
                    {loadingCities && (
                      <div className={styles.autocompleteLoading}>Завантаження...</div>
                    )}
                    {showCityDropdown && citySuggestions.length > 0 && (
                      <div className={styles.autocompleteDropdown}>
                        {citySuggestions.map((city) => (
                          <div
                            key={city.ref}
                            className={styles.autocompleteItem}
                            onClick={() => {
                              setNovaPoshtaData(prev => ({
                                ...prev,
                                cityQuery: city.name,
                                selectedCity: city,
                                selectedWarehouse: null
                              }));
                              setShowCityDropdown(false);
                            }}
                          >
                            <div className={styles.autocompleteCityName}>{city.name}</div>
                            <div className={styles.autocompleteCityArea}>{city.area}</div>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                  {novaPoshtaData.selectedCity && (
                    <p className={styles.fieldHintSuccess}>✓ Вибрано: {novaPoshtaData.selectedCity.name}</p>
                  )}
                </div>
                
                {/* Warehouse/Postomat Selection */}
                {novaPoshtaData.selectedCity && (
                  <div className={styles.formGroup}>
                    <label className={styles.label}>
                      {novaPoshtaData.deliveryType === "postomat" ? "Поштомат" : "Відділення"}
                    </label>
                    {loadingWarehouses ? (
                      <div className={styles.loadingWarehouses}>
                        Завантаження {novaPoshtaData.deliveryType === "postomat" ? "поштоматів" : "відділень"}...
                      </div>
                    ) : warehouseSuggestions.length > 0 ? (
                      <div className={styles.autocompleteWrapper}>
                        <select
                          value={novaPoshtaData.selectedWarehouse?.ref || ""}
                          onChange={(e) => {
                            const warehouse = warehouseSuggestions.find(w => w.ref === e.target.value);
                            setNovaPoshtaData(prev => ({ ...prev, selectedWarehouse: warehouse || null }));
                          }}
                          className={styles.select}
                        >
                          <option value="">
                            Оберіть {novaPoshtaData.deliveryType === "postomat" ? "поштомат" : "відділення"}
                          </option>
                          {warehouseSuggestions.map((warehouse) => (
                            <option key={warehouse.ref} value={warehouse.ref}>
                              {warehouse.description}
                            </option>
                          ))}
                        </select>
                      </div>
                    ) : (
                      <p className={styles.fieldHint}>
                        {novaPoshtaData.deliveryType === "postomat" 
                          ? "У цьому місті немає поштоматів. Спробуйте обрати відділення."
                          : "У цьому місті немає відділень."}
                      </p>
                    )}
                    {novaPoshtaData.selectedWarehouse && (
                      <div className={styles.warehouseDetails}>
                        <p className={styles.warehouseAddress}>
                          📍 {novaPoshtaData.selectedWarehouse.short_address || novaPoshtaData.selectedWarehouse.description}
                        </p>
                      </div>
                    )}
                  </div>
                )}
                
                {/* Phone Number */}
                <div className={styles.formGroup}>
                  <label className={styles.label}>Номер телефону одержувача</label>
                  <input
                    type="tel"
                    value={novaPoshtaData.recipientPhone}
                    onChange={(e) => setNovaPoshtaData(prev => ({ ...prev, recipientPhone: e.target.value }))}
                    className={styles.input}
                    placeholder="+380XXXXXXXXX"
                  />
                  <p className={styles.fieldHint}>Номер телефону для SMS-повідомлень про доставку</p>
                </div>
              </div>
            </div>
          )}

          {/* Store Pickup Map */}
          {deliveryMethod === "pickup" && (
            <div className={styles.section}>
              <h2 className={styles.sectionTitle}>Select Store Location</h2>
              <p className={styles.fieldHint} style={{ marginBottom: "16px" }}>
                Choose a store on the map to pick up your order
              </p>
              <DeliveryMapSimple type="store" />
            </div>
          )}

          {/* Nova Poshta Map */}
          {deliveryMethod === "nova_poshta" && novaPoshtaData.selectedCity && warehouseSuggestions.length > 0 && (
            <div className={styles.section}>
              <h2 className={styles.sectionTitle}>
                {novaPoshtaData.deliveryType === "postomat" ? "Карта поштоматів" : "Карта відділень"}
              </h2>
              <p className={styles.fieldHint} style={{ marginBottom: "16px" }}>
                Натисніть на маркер на карті щоб обрати {novaPoshtaData.deliveryType === "postomat" ? "поштомат" : "відділення"}
              </p>
              <DeliveryMapSimple
                type="nova_poshta"
                warehouses={warehouseSuggestions}
                deliveryType={novaPoshtaData.deliveryType}
                onSelectWarehouse={(warehouse) => {
                  setNovaPoshtaData(prev => ({ ...prev, selectedWarehouse: warehouse }));
                }}
                selectedWarehouse={novaPoshtaData.selectedWarehouse}
              />
              {novaPoshtaData.selectedWarehouse && (
                <div style={{ 
                  marginTop: "16px", 
                  padding: "12px", 
                  background: "#f0fdf4", 
                  border: "1px solid #86efac",
                  borderRadius: "8px"
                }}>
                  <p style={{ margin: 0, color: "#16a34a", fontWeight: "500" }}>
                    ✓ Вибрано: {novaPoshtaData.selectedWarehouse.description}
                  </p>
                </div>
              )}
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
