module Api
  module V1
    class CartsController < BaseController
      def items
        cart_items = current_user.cart_items.includes(:product)
        render json: CartItemSerializer.format_cart(cart_items), status: :ok
      end

      def add_item
        product = Product.find(params[:product_id])
        cart_item = current_user.cart_items.find_or_initialize_by(product: product)

        if cart_item.persisted?
          cart_item.quantity += params[:quantity].to_i
        else
          cart_item.quantity = params[:quantity].to_i
        end

        if cart_item.save
          cart_items = current_user.cart_items.includes(:product)
          render json: CartItemSerializer.format_cart(cart_items, message: "Product added to cart"),
                 status: :created
        else
          render json: {
            errors: cart_item.errors.full_messages
          }, status: :unprocessable_content
        end
      end

      def remove_item
        cart_item = current_user.cart_items.find_by!(product_id: params[:product_id])
        cart_item.destroy

        cart_items = current_user.cart_items.includes(:product)
        render json: CartItemSerializer.format_cart(cart_items, message: "Item removed from cart"),
               status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Item not found in cart" }, status: :not_found
      end

      def update_quantity
        cart_item = current_user.cart_items.find_by!(product_id: params[:product_id])

        if params[:quantity].to_i <= 0
          cart_item.destroy
        elsif !cart_item.update(quantity: params[:quantity])
          return render json: {
            errors: cart_item.errors.full_messages
          }, status: :unprocessable_entity
        end

        cart_items = current_user.cart_items.includes(:product)
        render json: CartItemSerializer.format_cart(cart_items, message: "Quantity updated"),
               status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Item not found in cart" }, status: :not_found
      end

      def clear
        current_user.cart_items.destroy_all
        render json: {
          message: "Cart cleared"
        }, status: :ok
      end
    end
  end
end
