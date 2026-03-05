module Api
  module V1
    class PaymentsController < BaseController
      skip_before_action :authenticate_user!, only: [ :webhook ]

      # POST /api/v1/payments/create_intent
      def create_intent
        order = current_user.orders.find(params[:order_id])

        payment_intent = Payments::StripeService.create_payment_intent(order)

        render json: {
          client_secret: payment_intent.client_secret,
          payment_intent_id: payment_intent.id
        }
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/payments/webhook
      def webhook
        payload = request.body.read
        sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

        if Payments::StripeService.handle_webhook(payload, sig_header)
          head :ok
        else
          head :bad_request
        end
      end
    end
  end
end
