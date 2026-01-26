Rails.application.routes.draw do
  get "registrations/new"
  get "registrations/create"
  get "customers/dashboard"
  get "/dashboard", to: "customers#dashboard", as: :customer_dashboard
  get "/profile", to: "customers#show_profile", as: :profile
  get "/profile/edit", to: "customers#edit_profile", as: :edit_profile
  patch "/profile", to: "customers#update_profile", as: :update_profile
  get "/orders", to: "customers#orders", as: :customer_orders

  root "customers#dashboard"

  resources :products, only: [:index, :show]

  resource :cart, only: [:show] do
    resources :cart_items, only: [:create, :destroy, :update]
  end

  get "/checkout", to: "checkout#new", as: :checkout
  patch "/checkout/update_step", to: "checkout#update_step", as: :checkout_update_step
  get "/checkout/payment", to: "checkout#payment", as: :checkout_payment
  post "/checkout/create_payment_intent", to: "checkout#create_payment_intent", as: :checkout_create_payment_intent
  post "/checkout/complete_payment", to: "checkout#complete_payment", as: :checkout_complete_payment
  post "/checkout", to: "checkout#create"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get  "/signup", to: "registrations#new"
  post "/signup", to: "registrations#create"
  
  get "/forgot-password", to: "password_resets#new", as: :forgot_password
  post "/password-resets", to: "password_resets#create", as: :password_resets
  get "/password-resets/:token/edit", to: "password_resets#edit", as: :edit_password_reset
  patch "/password-resets/:token", to: "password_resets#update", as: :password_reset

  namespace :admin do
    get "users/index"
    root "dashboard#index"
    resources :products
    resources :categories
    resources :orders, only: [:index, :show, :update]
    resources :categories
    resources :users, only: [:index, :destroy]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
