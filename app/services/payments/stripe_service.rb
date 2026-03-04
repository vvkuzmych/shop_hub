module Payments
  class StripeService
    class << self
      def create_payment_intent(order)
        Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

        payment_intent = Stripe::PaymentIntent.create(
          amount: (order.total_amount * 100).to_i, # Amount in cents
          currency: "usd",
          metadata: {
            order_id: order.id,
            user_id: order.user_id
          },
          automatic_payment_methods: {
            enabled: true
          }
        )

        order.update(
          payment_intent_id: payment_intent.id,
          payment_status: :payment_pending
        )

        payment_intent
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe Payment Intent Error: #{e.message}"
        raise StandardError, "Payment processing failed: #{e.message}"
      end

      def confirm_payment(payment_intent_id)
        Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        if payment_intent.status == "succeeded"
          order = Order.find_by(payment_intent_id: payment_intent_id)
          if order
            order.update(
              payment_status: :payment_paid,
              status: :payment_received
            )
          end
          true
        else
          false
        end
      rescue Stripe::StripeError => e
        Rails.logger.error "Stripe Confirmation Error: #{e.message}"
        false
      end

      def handle_webhook(payload, sig_header)
        Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
        endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

        event = Stripe::Webhook.construct_event(
          payload, sig_header, endpoint_secret
        )

        case event.type
        when "payment_intent.succeeded"
          payment_intent = event.data.object
          confirm_payment(payment_intent.id)
        when "payment_intent.payment_failed"
          payment_intent = event.data.object
          order = Order.find_by(payment_intent_id: payment_intent.id)
          order&.update(payment_status: :payment_failed)
        end

        true
      rescue Stripe::SignatureVerificationError => e
        Rails.logger.error "Stripe Webhook Signature Error: #{e.message}"
        false
      rescue => e
        Rails.logger.error "Stripe Webhook Error: #{e.message}"
        false
      end
    end
  end
end
