Rails.application.routes.draw do
  Rails.application.routes.draw do
    namespace :api do
      namespace :v1 do
        # Authentication
        post "/signup", to: "auth#signup"
        post "/login", to: "auth#login"
        delete "/logout", to: "auth#logout"

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
end
