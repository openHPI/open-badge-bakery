# frozen_string_literal: true

Rails.application.routes.draw do
  post 'bake', to: 'badges#create'
  resources :ping, only: [:index]
end
