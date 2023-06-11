Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root to: 'pages#index'
  resource :page, only: [:index]

  namespace :anecdotes do
    resources :tests
    resources :crons, only: [:index]
  end
end
