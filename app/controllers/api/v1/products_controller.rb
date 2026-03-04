module Api
  module V1
    class ProductsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index, :show, :search, :featured ]

      # GET /api/v1/products
      def index
        @products = Product.active.includes(:category, :reviews)
        @products = @products.search(params[:q]) if params[:q].present?
        @products = @products.by_category(params[:category_id]) if params[:category_id].present?
        @products = @products.where("price >= ?", params[:min_price]) if params[:min_price].present?
        @products = @products.where("price <= ?", params[:max_price]) if params[:max_price].present?
        @products = @products.in_stock if params[:in_stock] == "true"
        @products = @products.featured if params[:featured] == "true"
        @products = @products.page(params[:page]).per(params[:per_page] || 20)

        render json: ProductSerializer.new(@products, {
          include: [ :category ],
          meta: pagination_meta(@products)
        }).serializable_hash
      end

      # GET /api/v1/products/:id
      def show
        @product = Product.includes(:category, reviews: :user).find(params[:id])

        render json: ProductSerializer.new(@product, {
          include: [ :category, :reviews ]
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
        @products = Product.active.includes(:category)
        @products = @products.search(params[:q]) if params[:q].present?
        @products = @products.page(params[:page]).per(params[:per_page] || 20)

        render json: ProductSerializer.new(@products, {
          include: [ :category ],
          meta: pagination_meta(@products)
        }).serializable_hash
      end

      # GET /api/v1/products/featured
      def featured
        @products = Product.featured.in_stock.includes(:category).limit(params[:limit] || 10)

        render json: ProductSerializer.new(@products, {
          include: [ :category ]
        }).serializable_hash
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
