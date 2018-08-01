Rails.application.routes.draw do
  post 'bake', to: 'badges#create'
end
