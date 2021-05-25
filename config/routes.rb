Rails.application.routes.draw do
  root to: "products#index"
  devise_for :users

  resources :products do
    get "purchase", on: :member
  end

  resources :discounts do
    get "active", on: :collection
  end

  get "/admin", to: "pages#admin"
  get "/about", to: "pages#about"
  get "/purchased", to: "pages#purchased"
end
