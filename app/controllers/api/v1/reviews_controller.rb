module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index ]
      before_action :set_product

      def index
        reviews = @product.reviews.includes(:user)
        render json: ReviewSerializer.format_collection(reviews), status: :ok
      end

      def create
        review = @product.reviews.build(review_params)
        review.user = current_user

        if review.save
          render json: {
            message: "Review created successfully",
            review: ReviewSerializer.new(review).serializable_hash
          }, status: :created
        else
          render json: {
            errors: review.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_product
        @product = Product.find(params[:product_id])
      end

      def review_params
        params.require(:review).permit(:rating, :comment)
      end
    end
  end
end
