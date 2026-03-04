module Paginable
  extend ActiveSupport::Concern

  # Метод для створення pagination metadata
  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      next_page: collection.next_page,
      prev_page: collection.prev_page,
      total_pages: collection.total_pages,
      total_count: collection.total_count
    }
  end

  # Метод для отримання параметрів пагінації
  def pagination_params
    {
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    }
  end
end
