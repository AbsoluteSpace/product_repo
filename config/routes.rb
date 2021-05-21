Rails.application.routes.draw do
  get 'products/index'
  get 'discounts/index'
  devise_for :users

  resources :discounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
