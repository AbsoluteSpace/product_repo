Rails.application.routes.draw do
  root to: "products#index"
  devise_for :users

  resources :discounts, :products
  get '/products/purchase/:id', to: "products#purchase"
end
