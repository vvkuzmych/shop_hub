module Api
  module V1
    class CategoriesController < BaseController
      skip_before_action :authenticate_user!, only: [ :index, :show, :products ]

      def index
        categories = Category.root_categories.ordered.includes(:children)
        render json: categories.map { |category|
          {
            id: category.id,
            name: category.name,
            description: category.description,
            parent_id: category.parent_id,
            subcategories: category.children.map { |child|
              {
                id: child.id,
                name: child.name,
                description: child.description
              }
            }
          }
        }, status: :ok
      end

      def show
        category = Category.find(params[:id])
        render json: {
          id: category.id,
          name: category.name,
          description: category.description,
          parent_id: category.parent_id,
          subcategories: category.children.map { |child|
            {
              id: child.id,
              name: child.name,
              description: child.description
            }
          }
        }, status: :ok
      end

      def products
        category = Category.find(params[:id])
        products = category.all_products.available
        products = products.page(params[:page] || 1).per(params[:per_page] || 20)

        render json: ProductSerializer.new(products).serializable_hash, status: :ok
      end
    end
  end
end
