Rails.application.routes.draw do
  # Mount Swagger UI only in development
  if Rails.env.development? && defined?(Rswag)
    mount Rswag::Ui::Engine => "/api-docs"
    mount Rswag::Api::Engine => "/api-docs"
  end

  # Devise routes OUTSIDE namespace to avoid conflicts
  devise_for :users, path: "api/v1", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  }, controllers: {
    sessions: "api/v1/sessions",
    registrations: "api/v1/registrations",
    passwords: "api/v1/passwords"
  }

  namespace :api do
    namespace :v1 do
      # Resources (RESTful routes)
      resources :products do
        resources :reviews, only: [ :index, :create ]

        collection do
          get :search
          get :featured
        end
      end

      resources :categories do
        member do
          get :products
        end
      end

      resources :orders, only: [ :index, :show, :create, :update ] do
        member do
          patch :cancel
        end
      end

      # Cart
      resource :cart, only: [] do
        post :add_item
        delete :remove_item
        patch :update_quantity
        get :items
        delete :clear
      end

      # Admin routes
      namespace :admin do
        resources :products
        resources :categories
        resources :orders, only: [ :index, :show, :update ]
        resources :users, only: [ :index, :show ]
      end
    end
  end
end
