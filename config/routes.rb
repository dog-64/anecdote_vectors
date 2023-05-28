Rails.application.routes.draw do
  # resources :anecdotes
  # get 'pages/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: 'pages#index'
  resource :page, only: [:index]
  # resource :anecdote
end
