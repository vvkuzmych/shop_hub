module Api
  module V1
    class BaseController < ApplicationController
      include ExceptionHandler   # Custom module для errors
      include Paginable          # Custom module для pagination

      before_action :authenticate_user!  # Devise provides this method
      # current_user is provided by Devise
    end
  end
end
