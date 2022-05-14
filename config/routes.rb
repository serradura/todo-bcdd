# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :users do
    get '/sign_in', to: 'sessions#new'
    get '/sign_up', to: 'registrations#new'
    get '/reset_password', to: 'passwords#new'

    post '/sign_in', to: 'sessions#create', as: 'session'

    delete '/logout', to: 'sessions#destroy'
  end

  namespace :todos do
    get '/new', to: 'item#new'
    get '/edit/:id', to: 'item#edit', as: :edit

    scope module: :list do
      get '/completed', to: 'completed#index'
      get '/uncompleted', to: 'uncompleted#index'
    end
  end

  root to: redirect('/users/sign_in')
end
