import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { useAuthStore } from "../store/authStore";
import { authApi } from "../api/auth";
import { UserPlus } from "lucide-react";
import styles from "./Signup.module.css";

const Signup = () => {
  const [formData, setFormData] = useState({
    email: "",
    password: "",
    password_confirmation: "",
    first_name: "",
    last_name: "",
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const { setAuth } = useAuthStore();
  const navigate = useNavigate();

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (formData.password !== formData.password_confirmation) {
      setError("Passwords do not match");
      return;
    }

    setLoading(true);

    try {
      const response = await authApi.signup(formData);
      const token = localStorage.getItem("token");
      if (token) {
        setAuth(response.user, token);
        navigate("/products");
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "Signup failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.card}>
        <div className={styles.header}>
          <UserPlus className={styles.icon} />
          <h2 className={styles.title}>Create Account</h2>
          <p className={styles.subtitle}>Join ShopHub today</p>
        </div>

        {error && (
          <div className={styles.error}>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className={styles.form}>
          <div className={styles.formGrid}>
            <div className={styles.formGroup}>
              <label htmlFor="first_name" className={styles.label}>
                First Name
              </label>
              <input
                id="first_name"
                name="first_name"
                type="text"
                value={formData.first_name}
                onChange={handleChange}
                className={styles.input}
                placeholder="John"
                required
              />
            </div>

            <div className={styles.formGroup}>
              <label htmlFor="last_name" className={styles.label}>
                Last Name
              </label>
              <input
                id="last_name"
                name="last_name"
                type="text"
                value={formData.last_name}
                onChange={handleChange}
                className={styles.input}
                placeholder="Doe"
                required
              />
            </div>
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="email" className={styles.label}>
              Email
            </label>
            <input
              id="email"
              name="email"
              type="email"
              value={formData.email}
              onChange={handleChange}
              className={styles.input}
              placeholder="your@email.com"
              required
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="password" className={styles.label}>
              Password
            </label>
            <input
              id="password"
              name="password"
              type="password"
              value={formData.password}
              onChange={handleChange}
              className={styles.input}
              placeholder="••••••••"
              required
              minLength={6}
            />
          </div>

          <div className={styles.formGroup}>
            <label htmlFor="password_confirmation" className={styles.label}>
              Confirm Password
            </label>
            <input
              id="password_confirmation"
              name="password_confirmation"
              type="password"
              value={formData.password_confirmation}
              onChange={handleChange}
              className={styles.input}
              placeholder="••••••••"
              required
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className={styles.submitButton}
          >
            {loading ? "Creating account..." : "Sign Up"}
          </button>
        </form>

        <p className={styles.footer}>
          Already have an account?{" "}
          <Link to="/login" className={styles.footerLink}>
            Login
          </Link>
        </p>
      </div>
    </div>
  );
};

export default Signup;
