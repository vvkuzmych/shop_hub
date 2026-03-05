module Api
  module V1
    class CartsController < BaseController
      def items
        cart_items = current_user.cart_items.includes(:product)
        render json: {
          cart_items: cart_items.map { |item|
            {
              id: item.id,
              product_id: item.product_id,
              product_name: item.product.name,
              quantity: item.quantity,
              price: item.price.to_f,
              subtotal: item.subtotal.to_f,
              stock: item.product.stock
            }
          },
          total: cart_items.sum(&:subtotal).to_f
        }, status: :ok
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
          render json: {
            message: "Product added to cart",
            cart_item: cart_item
          }, status: :created
        else
          render json: {
            errors: cart_item.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def remove_item
        cart_item = current_user.cart_items.find_by!(product_id: params[:product_id])
        cart_item.destroy
        
        # Return updated cart
        cart_items = current_user.cart_items.includes(:product)
        render json: {
          message: "Item removed from cart",
          cart_items: cart_items.map { |item|
            {
              id: item.id,
              product_id: item.product_id,
              product_name: item.product.name,
              quantity: item.quantity,
              price: item.price.to_f,
              subtotal: item.subtotal.to_f,
              stock: item.product.stock
            }
          },
          total: cart_items.sum(&:subtotal).to_f
        }, status: :ok
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

        # Return updated cart
        cart_items = current_user.cart_items.includes(:product)
        render json: {
          message: "Quantity updated",
          cart_items: cart_items.map { |item|
            {
              id: item.id,
              product_id: item.product_id,
              product_name: item.product.name,
              quantity: item.quantity,
              price: item.price.to_f,
              subtotal: item.subtotal.to_f,
              stock: item.product.stock
            }
          },
          total: cart_items.sum(&:subtotal).to_f
        }, status: :ok
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
