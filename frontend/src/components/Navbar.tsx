import { Link, useNavigate } from "react-router-dom";
import { ShoppingCart, User, LogOut, Package } from "lucide-react";
import { useAuthStore } from "../store/authStore";
import { useCartStore } from "../store/cartStore";
import { authApi } from "../api/auth";
import styles from "./Navbar.module.css";

const Navbar = () => {
  const { isAuthenticated, user, logout } = useAuthStore();
  const { itemCount } = useCartStore();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await authApi.logout();
      logout();
      navigate("/");
    } catch (error) {
      console.error("Logout failed:", error);
      logout();
      navigate("/");
    }
  };

  return (
    <nav className={styles.navbar}>
      <div className={styles.container}>
        <div className={styles.content}>
          <Link to="/" className={styles.logo}>
            <Package className="w-8 h-8 inline mr-2" />
            ShopHub
          </Link>

          <div className={styles.actions}>
            <Link to="/products" className={styles.navLink}>
              Products
            </Link>

            {isAuthenticated ? (
              <>
                <Link to="/orders" className={styles.navLink}>
                  Orders
                </Link>

                <Link to="/cart" className={styles.cartButton}>
                  <ShoppingCart className="w-6 h-6" />
                  {itemCount() > 0 && (
                    <span className={styles.cartBadge}>
                      {itemCount()}
                    </span>
                  )}
                </Link>

                <div className={styles.userMenu}>
                  <User className="w-5 h-5" />
                  <span className="text-sm">{user?.first_name}</span>
                </div>

                <button onClick={handleLogout} className={styles.logoutButton}>
                  <LogOut className="w-5 h-5" />
                  <span className="text-sm ml-1">Logout</span>
                </button>
              </>
            ) : (
              <>
                <Link to="/login" className={styles.authButton}>
                  Login
                </Link>
                <Link to="/signup" className={styles.signupButton}>
                  Sign Up
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
