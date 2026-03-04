# ShopHub Frontend

Modern React + TypeScript e-commerce frontend for ShopHub API.

## Tech Stack

- **React 18** with TypeScript
- **Vite** for blazing fast development
- **React Router** for navigation
- **TanStack Query** for data fetching
- **Zustand** for state management
- **Axios** for API calls
- **Tailwind CSS** for styling
- **Lucide React** for icons

## Features

### Customer Features
- ✅ User authentication (Login/Signup)
- ✅ Product browsing with search and filters
- ✅ Product details with reviews
- ✅ Shopping cart management
- ✅ Order placement and history
- ✅ Responsive design

### UI Components
- Modern, clean design with Tailwind CSS
- Loading skeletons
- Error handling
- Toast notifications
- Protected routes

## Getting Started

### Prerequisites
- Node.js 20.x
- npm or yarn
- Rails API running on `http://localhost:3000`

### Installation

```bash
cd frontend
npm install
```

### Configuration

Create `.env` file:
```bash
VITE_API_URL=http://localhost:3000/api/v1
```

### Development

```bash
# Start development server
npm run dev

# Open browser
# http://localhost:5173
```

### Build for Production

```bash
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
frontend/
├── src/
│   ├── api/              # API client layer
│   │   ├── axios.ts      # Axios configuration
│   │   ├── auth.ts       # Auth endpoints
│   │   ├── products.ts   # Product endpoints
│   │   ├── cart.ts       # Cart endpoints
│   │   └── orders.ts     # Order endpoints
│   ├── components/       # Reusable components
│   │   ├── Navbar.tsx    # Navigation bar
│   │   └── PrivateRoute.tsx # Route protection
│   ├── pages/            # Page components
│   │   ├── Home.tsx      # Landing page
│   │   ├── Products.tsx  # Product listing
│   │   ├── ProductDetail.tsx # Product details
│   │   ├── Cart.tsx      # Shopping cart
│   │   ├── Orders.tsx    # Order history
│   │   ├── Login.tsx     # Login page
│   │   └── Signup.tsx    # Signup page
│   ├── store/            # State management
│   │   ├── authStore.ts  # Authentication state
│   │   └── cartStore.ts  # Cart state
│   ├── types/            # TypeScript types
│   │   └── index.ts      # Type definitions
│   ├── App.tsx           # Main app component
│   ├── main.tsx          # Entry point
│   └── index.css         # Global styles
├── public/               # Static assets
├── .env                  # Environment variables
├── package.json          # Dependencies
├── tailwind.config.js    # Tailwind configuration
├── tsconfig.json         # TypeScript configuration
└── vite.config.ts        # Vite configuration
```

## API Integration

The frontend connects to the Rails API at:
- Default: `http://localhost:3000/api/v1`
- Configurable via `VITE_API_URL` environment variable

### Authentication
- JWT tokens stored in localStorage
- Auto-attached to requests via Axios interceptor
- Auto-redirect to login on 401 errors

### Endpoints Used
- `POST /signup` - User registration
- `POST /login` - User login
- `DELETE /logout` - User logout
- `GET /products` - List products (with filters)
- `GET /products/:id` - Product details
- `GET /products/featured` - Featured products
- `GET /cart/items` - Get cart
- `POST /cart/add_item` - Add to cart
- `PATCH /cart/update_quantity` - Update quantity
- `DELETE /cart/remove_item` - Remove from cart
- `GET /orders` - Order history
- `POST /orders` - Create order
- `PATCH /orders/:id/cancel` - Cancel order

## Usage

### Running with Rails Backend

1. **Start Rails API:**
```bash
cd /Users/vkuzm/RubymineProjects/shop_hub
rails server
```

2. **Start React Frontend:**
```bash
cd /Users/vkuzm/RubymineProjects/shop_hub/frontend
npm run dev
```

3. **Open browser:**
```
http://localhost:5173
```

### Default Test User
- Email: `admin@shophub.com`
- Password: `password`

Or create a new account via Signup page.

## Development Tips

### Hot Module Replacement
Vite provides instant HMR - changes appear immediately without full page reload.

### TypeScript
Full type safety with TypeScript. Types are defined in `src/types/index.ts`.

### State Management
- **Auth State**: `useAuthStore()` - user, token, isAuthenticated
- **Cart State**: `useCartStore()` - items, total, itemCount

### Adding New Pages
1. Create component in `src/pages/`
2. Add route in `App.tsx`
3. Update navigation in `Navbar.tsx`

## Troubleshooting

### CORS Errors
Make sure Rails CORS is configured in `config/initializers/cors.rb`:
```ruby
origins "localhost:5173", "localhost:3001"
```

### API Connection Failed
- Check Rails server is running: `rails server`
- Verify API URL in `.env` file
- Check browser console for errors

### Authentication Issues
- Clear localStorage: `localStorage.clear()`
- Check JWT token in browser DevTools
- Verify token in API responses

## Scripts

```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run preview      # Preview production build
npm run lint         # Run ESLint
```

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## License

Proprietary - ShopHub
