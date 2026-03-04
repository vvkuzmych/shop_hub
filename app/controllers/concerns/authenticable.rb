module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  # current_user is provided by Devise
  # authenticate_user! is provided by Devise
end
