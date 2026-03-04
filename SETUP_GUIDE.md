# 🚀 ShopHub - Setup Guide

## Environment Variables

### Backend (.env)
Create `/Users/vkuzm/RubymineProjects/shop_hub/.env`:

```bash
# Stripe Keys (Get from https://dashboard.stripe.com/test/apikeys)
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Frontend URL (for email links)
FRONTEND_URL=http://localhost:5173
```

### Frontend (.env)
Create `/Users/vkuzm/RubymineProjects/shop_hub/frontend/.env`:

```bash
# API URL
VITE_API_URL=http://localhost:3000

# Stripe Publishable Key (Get from https://dashboard.stripe.com/test/apikeys)
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
```

---

## 🔑 Getting Stripe Test Keys

1. Go to: https://dashboard.stripe.com/test/apikeys
2. Copy your **Publishable key** (starts with `pk_test_`)
3. Copy your **Secret key** (starts with `sk_test_`)
4. For webhook secret:
   - Install Stripe CLI: `brew install stripe/stripe-cli/stripe`
   - Run: `stripe listen --forward-to localhost:3000/api/v1/payments/webhook`
   - Copy the webhook signing secret (starts with `whsec_`)

---

## 🧪 Testing with Stripe Test Cards

Use these test card numbers in the payment form:

### Successful Payment
```
Card: 4242 4242 4242 4242
Exp: Any future date (e.g., 12/25)
CVC: Any 3 digits (e.g., 123)
ZIP: Any 5 digits (e.g., 12345)
```

### Failed Payment
```
Card: 4000 0000 0000 0002
(Card will be declined)
```

### 3D Secure Required
```
Card: 4000 0025 0000 3155
(Will prompt for 3D Secure authentication)
```

---

## 🏃 Running the Application

### Backend (Rails)
```bash
cd /Users/vkuzm/RubymineProjects/shop_hub

# Start Rails server
rails server

# In another terminal, start Sidekiq (for background jobs/emails)
bundle exec sidekiq
```

### Frontend (React)
```bash
cd /Users/vkuzm/RubymineProjects/shop_hub/frontend

# Start dev server
npm run dev
```

### Stripe Webhook Listener (Development)
```bash
# In another terminal
stripe listen --forward-to localhost:3000/api/v1/payments/webhook
```

---

## 📧 Email Configuration

For development, emails are logged to console by default.

To actually send emails, configure in `config/environments/development.rb`:

```ruby
# Using Gmail (example)
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  user_name: ENV["GMAIL_USERNAME"],
  password: ENV["GMAIL_APP_PASSWORD"],
  authentication: "plain",
  enable_starttls_auto: true
}
```

Or use a service like Mailgun, SendGrid, or Postmark.

---

## 🔄 Complete Order Flow

1. **Browse Products** → http://localhost:5173/products
2. **Add to Cart** → Click "Add to Cart" on any product
3. **View Cart** → http://localhost:5173/cart
4. **Checkout** → Click "Proceed to Checkout"
5. **Select Delivery**:
   - Choose "Home Delivery" and enter address
   - OR choose "Store Pickup"
6. **Place Order** → Click "Proceed to Payment"
7. **Pay** → Enter test card `4242 4242 4242 4242`
8. **Track Order** → Automatically redirected to tracking page
9. **Receive Emails**:
   - Order confirmation email
   - Status update emails (when admin changes status)

---

## 🎯 Admin Features (To Be Implemented)

For now, you can update order status manually:

```ruby
# Rails console
rails console

# Find an order
order = Order.find(1)

# Update status
order.update(status: :payment_received)
order.update(status: :processing)
order.update(status: :packed)
order.update(status: :shipped, tracking_number: "TRACK123")
order.update(status: :delivered)

# Each update sends an email automatically!
```

---

## ✅ Verification Checklist

- [ ] Backend `.env` file created with Stripe keys
- [ ] Frontend `.env` file created with Stripe publishable key
- [ ] Rails server running on port 3000
- [ ] React dev server running on port 5173
- [ ] Stripe webhook listener running
- [ ] Can place order and proceed to checkout
- [ ] Payment form loads with Stripe elements
- [ ] Test payment succeeds
- [ ] Order tracking page displays
- [ ] Emails are logged/sent

---

## 🐛 Troubleshooting

### "Payment form not loading"
- Check VITE_STRIPE_PUBLISHABLE_KEY in frontend/.env
- Verify key starts with `pk_test_`

### "Payment fails with 'Invalid API Key'"
- Check STRIPE_SECRET_KEY in backend/.env
- Verify key starts with `sk_test_`

### "Webhook not working"
- Make sure stripe CLI is running
- Check STRIPE_WEBHOOK_SECRET matches CLI output

### "Emails not sending"
- Check Rails logs for email output
- Configure SMTP settings if needed
- Verify OrderMailer is working in console

---

## 📚 Additional Resources

- Stripe Testing: https://stripe.com/docs/testing
- Stripe CLI: https://stripe.com/docs/stripe-cli
- Stripe Webhooks: https://stripe.com/docs/webhooks

---

**Status**: ✅ All code implemented, RuboCop clean, builds successful
**Ready**: Configure environment variables and test!
