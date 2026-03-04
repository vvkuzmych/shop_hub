module Api
  module V1
    module Admin
      class ProductsController < BaseController
        before_action :set_product, only: [ :show, :update, :destroy ]

        def index
          products = Product.includes(:category).page(params[:page] || 1).per(params[:per_page] || 20)
          render json: ProductSerializer.new(products, params: { admin: true }).serializable_hash, status: :ok
        end

        def show
          render json: ProductSerializer.new(@product, params: { admin: true }).serializable_hash, status: :ok
        end

        def create
          product = Product.new(product_params)

          if product.save
            render json: {
              message: "Product created successfully",
              product: ProductSerializer.new(product).serializable_hash
            }, status: :created
          else
            render json: {
              errors: product.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def update
          if @product.update(product_params)
            render json: {
              message: "Product updated successfully",
              product: ProductSerializer.new(@product).serializable_hash
            }, status: :ok
          else
            render json: {
              errors: @product.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def destroy
          @product.destroy
          render json: {
            message: "Product deleted successfully"
          }, status: :ok
        end

        private

        def set_product
          @product = Product.find(params[:id])
        end

        def product_params
          params.require(:product).permit(:name, :description, :price, :stock, :category_id, :sku, :active, images: [])
        end
      end
    end
  end
end
