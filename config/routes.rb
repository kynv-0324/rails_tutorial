Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi|jp/ do
    devise_for :accounts
    root to: 'public#main'
  end
end
