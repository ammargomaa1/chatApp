Rails.application.routes.draw do
  get 'application/index'
  post 'application/create', to: 'application#create'

  post '/:application_token/chat', to: 'chats#create'
  post '/:application_token/:chat_number/message', to: 'message#create'
  get '/:application_token/:chat_number/message/search', to: 'message#search'


  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
