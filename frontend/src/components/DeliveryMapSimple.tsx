import { useEffect, useRef } from "react";
import type { NovaPoshtaWarehouse, NovaPoshtaPostomat } from "../api/novaPoshta";

declare const L: any;

interface StoreLocation {
  id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  phone?: string;
  hours?: string;
}

interface DeliveryMapProps {
  type: "store" | "nova_poshta";
  warehouses?: (NovaPoshtaWarehouse | NovaPoshtaPostomat)[];
  deliveryType?: "warehouse" | "postomat";
  onSelectWarehouse?: (warehouse: NovaPoshtaWarehouse | NovaPoshtaPostomat) => void;
  selectedWarehouse?: NovaPoshtaWarehouse | NovaPoshtaPostomat | null;
}

export default function DeliveryMapSimple({
  type,
  warehouses = [],
  deliveryType = "warehouse",
  onSelectWarehouse,
  selectedWarehouse
}: DeliveryMapProps) {
  const mapRef = useRef<any>(null);
  const mapContainerRef = useRef<HTMLDivElement>(null);

  // Store locations
  const storeLocations: StoreLocation[] = [
    {
      id: "1",
      name: "Shop Hub - Main Store",
      address: "вул. Хрещатик, 1, Київ",
      lat: 50.4501,
      lng: 30.5234,
      phone: "+380 44 123 4567",
      hours: "9:00 - 21:00"
    },
    {
      id: "2",
      name: "Shop Hub - Podil",
      address: "вул. Сагайдачного, 25, Київ",
      lat: 50.4676,
      lng: 30.5174,
      phone: "+380 44 234 5678",
      hours: "10:00 - 20:00"
    },
    {
      id: "3",
      name: "Shop Hub - Obolon",
      address: "просп. Героїв Сталінграда, 8, Київ",
      lat: 50.5111,
      lng: 30.4983,
      phone: "+380 44 345 6789",
      hours: "9:00 - 22:00"
    }
  ];

  useEffect(() => {
    if (!mapContainerRef.current) return;

    // Wait for Leaflet to be available
    if (typeof L === "undefined") {
      const checkLeaflet = setInterval(() => {
        if (typeof L !== "undefined") {
          clearInterval(checkLeaflet);
          initializeMap();
        }
      }, 100);
      return () => clearInterval(checkLeaflet);
    }

    initializeMap();

    function initializeMap() {
      if (!mapContainerRef.current) return;

      // Remove existing map if already initialized
      if (mapRef.current) {
        mapRef.current.remove();
        mapRef.current = null;
      }

      // Clear the container's internal state
      const container = mapContainerRef.current;
      container.innerHTML = "";
      (container as any)._leaflet_id = undefined;

      // Initialize map
      const map = L.map(container).setView([50.4501, 30.5234], 11);
      mapRef.current = map;

    // Add tile layer
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);

    // Custom icons
    const storeIcon = L.icon({
      iconUrl: "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png",
      shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    const warehouseIcon = L.icon({
      iconUrl: "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png",
      shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    const postomatIcon = L.icon({
      iconUrl: "https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-blue.png",
      shadowUrl: "https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/images/marker-shadow.png",
      iconSize: [25, 41],
      iconAnchor: [12, 41],
      popupAnchor: [1, -34],
      shadowSize: [41, 41]
    });

    // Add store markers
    if (type === "store") {
      storeLocations.forEach((store) => {
        const marker = L.marker([store.lat, store.lng], { icon: storeIcon }).addTo(map);
        
        const popupContent = `
          <div style="min-width: 200px;">
            <h3 style="margin: 0 0 8px 0; font-size: 16px; font-weight: 600;">
              ${store.name}
            </h3>
            <p style="margin: 4px 0; font-size: 14px; color: #666;">
              📍 ${store.address}
            </p>
            ${store.phone ? `<p style="margin: 4px 0; font-size: 14px; color: #666;">📞 ${store.phone}</p>` : ""}
            ${store.hours ? `<p style="margin: 4px 0; font-size: 14px; color: #666;">🕐 ${store.hours}</p>` : ""}
          </div>
        `;
        
        marker.bindPopup(popupContent);
      });
    }

    // Add Nova Poshta markers
    if (type === "nova_poshta" && warehouses.length > 0) {
      const validWarehouses = warehouses.filter(w => w.latitude && w.longitude);
      const bounds: any[] = [];

      validWarehouses.forEach((warehouse) => {
        const lat = parseFloat(warehouse.latitude!);
        const lng = parseFloat(warehouse.longitude!);
        const icon = deliveryType === "postomat" ? postomatIcon : warehouseIcon;
        
        const marker = L.marker([lat, lng], { icon }).addTo(map);
        bounds.push([lat, lng]);

        const isSelected = selectedWarehouse?.ref === warehouse.ref;
        const popupContent = `
          <div style="min-width: 250px;">
            <h3 style="margin: 0 0 8px 0; font-size: 15px; font-weight: 600; color: ${isSelected ? "#22c55e" : "#000"}">
              ${warehouse.description}
            </h3>
            ${warehouse.short_address ? `<p style="margin: 4px 0; font-size: 13px; color: #666;">📍 ${warehouse.short_address}</p>` : ""}
            <button
              onclick="window.selectWarehouse('${warehouse.ref}')"
              style="
                margin-top: 8px;
                padding: 6px 12px;
                background: ${isSelected ? "#22c55e" : "#3b82f6"};
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 13px;
                font-weight: 500;
              "
            >
              ${isSelected ? "✓ Вибрано" : "Вибрати"}
            </button>
          </div>
        `;
        
        marker.bindPopup(popupContent);

        marker.on("click", () => {
          if (onSelectWarehouse) {
            onSelectWarehouse(warehouse);
          }
        });
      });

      // Fit bounds to show all warehouses
      if (bounds.length > 0) {
        map.fitBounds(bounds, { padding: [50, 50], maxZoom: 13 });
      }
    }

      // Expose warehouse selection to popup buttons
      (window as any).selectWarehouse = (ref: string) => {
        const warehouse = warehouses.find(w => w.ref === ref);
        if (warehouse && onSelectWarehouse) {
          onSelectWarehouse(warehouse);
        }
      };

      // Cleanup
      return () => {
        if (mapRef.current) {
          mapRef.current.remove();
          mapRef.current = null;
        }
        delete (window as any).selectWarehouse;
      };
    }
  }, [type, warehouses, deliveryType, selectedWarehouse]);

  return (
    <div
      ref={mapContainerRef}
      style={{
        height: "450px",
        width: "100%",
        borderRadius: "8px",
        overflow: "hidden",
        boxShadow: "0 2px 8px rgba(0,0,0,0.1)"
      }}
    />
  );
}
