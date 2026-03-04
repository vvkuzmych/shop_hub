module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index ]
      before_action :set_product

      def index
        reviews = @product.reviews.includes(:user)
        render json: reviews.map { |review|
          {
            id: review.id,
            rating: review.rating,
            comment: review.comment,
            user: {
              id: review.user.id,
              full_name: review.user.full_name
            },
            created_at: review.created_at
          }
        }, status: :ok
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
