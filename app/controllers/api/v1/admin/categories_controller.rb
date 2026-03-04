module Api
  module V1
    module Admin
      class CategoriesController < BaseController
        before_action :set_category, only: [ :show, :update, :destroy ]

        def index
          categories = Category.includes(:parent, :children).page(params[:page] || 1).per(params[:per_page] || 20)
          render json: categories.map { |category|
            {
              id: category.id,
              name: category.name,
              description: category.description,
              parent_id: category.parent_id,
              parent_name: category.parent&.name,
              subcategories_count: category.children.count,
              products_count: category.products.count
            }
          }, status: :ok
        end

        def show
          render json: {
            id: @category.id,
            name: @category.name,
            description: @category.description,
            parent_id: @category.parent_id,
            parent_name: @category.parent&.name,
            subcategories: @category.children.map { |child|
              {
                id: child.id,
                name: child.name
              }
            },
            products_count: @category.products.count
          }, status: :ok
        end

        def create
          category = Category.new(category_params)

          if category.save
            render json: {
              message: "Category created successfully",
              category: category
            }, status: :created
          else
            render json: {
              errors: category.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def update
          if @category.update(category_params)
            render json: {
              message: "Category updated successfully",
              category: @category
            }, status: :ok
          else
            render json: {
              errors: @category.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def destroy
          @category.destroy
          render json: {
            message: "Category deleted successfully"
          }, status: :ok
        end

        private

        def set_category
          @category = Category.find(params[:id])
        end

        def category_params
          params.require(:category).permit(:name, :description, :parent_id)
        end
      end
    end
  end
end
