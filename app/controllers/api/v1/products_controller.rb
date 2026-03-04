module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show, :search]

      # GET /api/v1/products
      def index
        @products = Product.active
                           .includes(:category, :reviews)
                           .page(params[:page])
                           .per(params[:per_page] || 20)

        render json: ProductSerializer.new(@products, {
          include: [:category],
          meta: pagination_meta(@products)
        }).serializable_hash
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.includes(:category, reviews: :user).find(params[:id])

        render json: ProductSerializer.new(@product, {
          include: [:category, :reviews]
        }).serializable_hash
      end

      # POST /api/v1/products (admin only)
      def create
        authorize Product  # Pundit authorization

        @product = Product.new(product_params)

        if @product.save
          render json: ProductSerializer.new(@product).serializable_hash, status: :created
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/products/:id
      def update
        @product = Product.find(params[:id])
        authorize @product

        if @product.update(product_params)
          render json: ProductSerializer.new(@product).serializable_hash
        else
          render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/products/:id
      def destroy
        @product = Product.find(params[:id])
        authorize @product

        @product.destroy
        head :no_content
      end

      # GET /api/v1/products/search
      def search
        @products = Product.active
                           .search(params[:q])
                           .page(params[:page])

        render json: ProductSerializer.new(@products).serializable_hash
      end

      private

      # Strong parameters (Rails security)
      def product_params
        params.require(:product).permit(
          :name, :description, :price, :stock, :category_id, :sku, :active, images: []
        )
      end
    end
  end
end
