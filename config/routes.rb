Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi|jp/ do
    root "static_pages#home"

    get "/help", to: "static_pages#help"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"
    get  "/signup",  to: "users#new"
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"
    get '/microposts', to: 'static_pages#home'

    # create /users/1/following and /users/1/followers path [get method]
    resources :users do
      resources :followings, only: :index
      resources :followers, only: :index
    end
    resources :account_activations, only: [:edit]
    resources :password_resets,     only: [:new, :create, :edit, :update]
    resources :microposts,          only: [:create, :destroy]
    resources :relationships,       only: [:create, :destroy]
  end
end
