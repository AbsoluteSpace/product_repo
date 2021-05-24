Rails.application.routes.draw do
  root to: "products#index"
  devise_for :users

  resources :products
  resources :discounts do
    collection do
      get 'active'
    end
  end
  get '/admin', to: "pages#admin"
  get '/about', to: "pages#about"
  get '/purchased', to: "pages#purchased"
  get '/products/purchase/:id', to: "products#purchase"
end
