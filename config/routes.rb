Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :admin do
    get "/sign_in", to: "sessions#new"
    post "/sign_in", to: "sessions#create"
    delete "/sign_out", to: "sessions#destroy"

    resources :merchants
    resources :transactions, only: [:index]

    root to: "static#index"
  end

  scope :api do
    api_guard_routes for: "merchants", only: ["authentication"]
  end

  namespace :api do
    resources :transactions, only: [:index, :create]
  end

  root to: "static#index"
end
