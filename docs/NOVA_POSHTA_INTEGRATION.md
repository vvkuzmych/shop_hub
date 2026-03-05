# Nova Poshta Integration

## Overview

Nova Poshta is a Ukrainian delivery service that allows customers to receive packages at convenient warehouse locations throughout Ukraine. This feature is integrated into the ShopHub checkout process as a third delivery option alongside Home Delivery and Store Pickup.

**Official Website**: [https://novaposhta.ua/](https://novaposhta.ua/)

## Features

### Customer-Facing Features

1. **Delivery Method Selection**
   - Customers can choose "Nova Poshta" as their delivery method during checkout
   - Choice between **Warehouse** (Відділення) or **Parcel Locker** (Поштомат) delivery

2. **Real-time API Integration**
   - **City Autocomplete**: Type-ahead search for cities using Nova Poshta API
   - **Dynamic Warehouse Loading**: Automatically loads warehouses/postomats based on selected city
   - **Live Data**: Always shows current, active delivery points

3. **Required Information**
   - **Delivery Type**: Warehouse or Parcel Locker (Postomat)
   - **City**: Autocomplete search for Ukrainian cities
   - **Warehouse/Postomat**: Dropdown selection with full addresses
   - **Recipient Phone**: Contact phone number for SMS notifications

4. **User Experience**
   - Modern autocomplete interface with search suggestions
   - Visual feedback for selected city and warehouse
   - Displays full warehouse addresses with map markers
   - Ukrainian language interface for Nova Poshta section
   - Validation ensures all required fields are filled

### Technical Implementation

#### Nova Poshta API Integration

**API Client**: `app/services/nova_poshta/api_client.rb`

The service integrates with Nova Poshta API v2.0 at `https://api.novaposhta.ua/v2.0/json/`

**Available Methods**:
- `search_cities(query)` - Search cities by name (minimum 2 characters)
- `get_warehouses(city_ref, warehouse_type:)` - Get warehouses for a city
- `get_postomats(city_ref)` - Get parcel lockers for a city
- `get_warehouse_types()` - Get available warehouse types

**Security**:
- ✅ SSL certificate verification enabled (proper HTTPS validation)
- All API requests use secure HTTPS connection to Nova Poshta servers
- API key stored in environment variables (never committed to git)

**API Endpoints**: `app/controllers/api/v1/nova_poshta_controller.rb`

- `GET /api/v1/nova_poshta/cities?query=Київ` - Search cities
- `GET /api/v1/nova_poshta/warehouses?city_ref=...&type=...` - Get warehouses
- `GET /api/v1/nova_poshta/postomats?city_ref=...` - Get postomats

**Environment Variable**:
```bash
NOVA_POSHTA_API_KEY=your_api_key_here
```

Get your API key from: https://my.novaposhta.ua/settings/index#apikeys

**Note**: The integration works without an API key for development, but you'll need a real key for production use.

#### Backend (Rails)

**Order Model** (`app/models/order.rb`)
```ruby
enum :delivery_method, {
  delivery: 0,          # Home delivery
  pickup: 1,            # Store pickup
  nova_poshta: 2        # Nova Poshta (Ukrainian delivery service)
}
```

**Validation**
- Nova Poshta orders require a `delivery_address` field (same as home delivery)
- The address is formatted as:
  ```
  Nova Poshta
  City: [City Name]
  Warehouse: [Branch/Warehouse]
  Phone: [Phone Number]
  ```

**Database**
- No additional columns required
- Uses existing `delivery_method` enum (integer value 2)
- Uses existing `delivery_address` text field

#### Frontend (React)

**Component**: `frontend/src/pages/Checkout.tsx`

**State Management**
```typescript
const [novaPoshtaData, setNovaPoshtaData] = useState({
  cityQuery: "",
  selectedCity: null as NovaPoshtaCity | null,
  deliveryType: "warehouse" as "warehouse" | "postomat",
  selectedWarehouse: null as (NovaPoshtaWarehouse | NovaPoshtaPostomat) | null,
  recipientPhone: ""
});
```

**API Client**: `frontend/src/api/novaPoshta.ts`

Provides methods to interact with Nova Poshta endpoints:
- `searchCities(query)` - Search for cities with autocomplete
- `getWarehouses(cityRef, type?)` - Load warehouses by city
- `getPostomats(cityRef)` - Load parcel lockers by city

**Features**:
- Real-time city search with debouncing
- Autocomplete dropdown with city and region display
- Dynamic warehouse loading based on selected city and type
- Visual feedback for selections
- Address formatting for backend storage

**Type Safety**: `frontend/src/api/orders.ts`
```typescript
export interface CreateOrderData {
  // ...
  delivery_method?: "delivery" | "pickup" | "nova_poshta";
  // ...
}
```

## Usage Guide

### For Customers

1. **During Checkout**:
   - Select "Nova Poshta" (🚚 Nova Poshta) delivery option
   - **Choose delivery type**: 
     - 🏪 Відділення (Warehouse/Branch)
     - 📦 Поштомат (Parcel Locker)
   - **Select city**: Start typing your city name (e.g., "Київ", "Львів", "Одеса")
     - Suggestions will appear as you type
     - Select your city from the dropdown
   - **Select warehouse/postomat**: 
     - A dropdown will automatically load available locations
     - Each option shows the full address
     - Select your preferred delivery point
   - **Enter phone number**: Provide your mobile number for SMS notifications (e.g., "+380501234567")

2. **After Order Placement**:
   - You'll receive order confirmation with your Nova Poshta details
   - Track your order status through the ShopHub tracking page
   - You'll receive a tracking number (format: NP + 11 digits)
   - Nova Poshta will send SMS notifications about your package
   - Pick up your package at the selected warehouse or postomat when it arrives

### For Administrators

1. **Viewing Orders**:
   - Nova Poshta orders are marked with `delivery_method: "nova_poshta"`
   - The `delivery_address` field contains formatted Nova Poshta details

2. **Processing Orders**:
   - When an order is ready to ship, update status to "shipped"
   - Assign a Nova Poshta tracking number (format: `NP` + 11 digits)
   - Email notifications will be sent to customers automatically

3. **Seed Data**:
   - Run `rails runner db/seeds_order_tracking.rb` to create test Nova Poshta orders
   - Sample order includes realistic Ukrainian address format

## Current Implementation Status

✅ **Completed Features**:
- Nova Poshta API v2.0 integration
- City autocomplete with real-time search
- Dynamic warehouse/postomat loading
- Delivery type selection (warehouse vs postomat)
- Full address display and selection
- Backend service for API communication
- Frontend React components with TypeScript
- Proper error handling and loading states
- Ukrainian language interface

## Future Enhancements

### Potential Additional Features

1. **Shipping Cost Calculation**
   - Calculate delivery costs based on weight and dimensions
   - Display shipping costs during checkout
   - Integrate with Nova Poshta pricing API

2. **Real-time Tracking Integration**
   - Pull live tracking updates from Nova Poshta
   - Show detailed package journey
   - Automatic status synchronization

3. **Enhanced Validation**
   - Validate phone number format (Ukrainian mobile numbers)
   - Add phone number verification via SMS
   - Validate package dimensions and weight limits

4. **Improved UX**
   - Map view showing warehouse locations
   - Display warehouse working hours in selection
   - Show distance from customer's location
   - Add warehouse photos and ratings
   - Show estimated delivery date during checkout

5. **Admin Features**
   - Bulk label generation for Nova Poshta orders
   - Automatic tracking number assignment from Nova Poshta
   - Integration with Nova Poshta merchant dashboard
   - Real-time status sync with webhooks
   - Generate shipping manifests

**API Documentation**: 
- [Nova Poshta API Portal](https://developers.novaposhta.ua/)
- [API Methods Documentation](https://api-portal.novapost.com/en/api-methods/)

## Testing

### Setup

1. **Get Nova Poshta API Key** (Optional for testing):
   - Visit https://my.novaposhta.ua/settings/index#apikeys
   - Register or login to your Nova Poshta account
   - Generate an API key
   - Add to your `.env` file:
     ```bash
     NOVA_POSHTA_API_KEY=your_api_key_here
     ```

2. **Start the Application**:
   ```bash
   make start
   # or
   rails server  # Backend on port 3000
   cd frontend && npm run dev  # Frontend on port 5175
   ```

### Manual Testing

1. **Test City Autocomplete**:
   - Navigate to `http://localhost:5175/checkout`
   - Add items to cart first
   - Select "Nova Poshta" delivery option
   - Type "Київ" or "Львів" in the city field
   - Verify autocomplete suggestions appear
   - Select a city from dropdown

2. **Test Warehouse/Postomat Loading**:
   - After selecting a city, warehouses should load automatically
   - Try switching between "Відділення" and "Поштомат"
   - Verify dropdown shows different locations
   - Select a warehouse and verify address displays

3. **Complete Order**:
   - Fill in phone number: +380501234567
   - Proceed to payment
   - Verify order creation with Nova Poshta details

4. **Run Seed Script**:
   ```bash
   rails runner db/seeds_order_tracking.rb
   ```
   This creates a sample Nova Poshta order in "shipped" status.

5. **Verify Order Details**:
   - Check order tracking page
   - Verify delivery address format includes city, warehouse, and phone
   - Confirm delivery method shows "nova_poshta"

### Automated Testing

**RSpec Examples** (to be implemented):

```ruby
# spec/models/order_spec.rb
describe Order do
  describe "nova_poshta delivery" do
    it "requires delivery_address when delivery_method is nova_poshta" do
      order = build(:order, delivery_method: :nova_poshta, delivery_address: nil)
      expect(order).not_to be_valid
      expect(order.errors[:delivery_address]).to include("can't be blank")
    end
    
    it "formats Nova Poshta address correctly" do
      order = create(:order, 
        delivery_method: :nova_poshta,
        delivery_address: "Nova Poshta\nCity: Kyiv\nWarehouse: Branch #42\nPhone: +380501234567"
      )
      expect(order.nova_poshta?).to be true
      expect(order.delivery_address).to include("Nova Poshta")
    end
  end
end
```

## References

- **Nova Poshta Official Website**: [https://novaposhta.ua/](https://novaposhta.ua/)
- **Nova Poshta API Documentation**: [https://developers.novaposhta.ua/](https://developers.novaposhta.ua/)
- **Related Documentation**: 
  - [docs/SEEDING_DATA.md](./SEEDING_DATA.md) - Includes Nova Poshta seed examples
  - [docs/README.md](./README.md) - Main documentation index

## Support

For questions or issues related to Nova Poshta integration:
1. Check the Nova Poshta website for warehouse locations and services
2. Review this documentation for implementation details
3. Contact Nova Poshta customer support for delivery-specific questions

---

*Last Updated: February 25, 2026*
