Rails.application.routes.draw do
  post 'bake', to: 'badges#create'
  resources :ping, only: [:index]
end
