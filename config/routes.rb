# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  user_access = ->(request) { request.env['warden'].authenticated?(:user) }
  guest_access = ->(request) { !user_access[request] }

  constraints guest_access do
    namespace :users do
      get '/sign_in', to: 'sessions#new'
      get '/sign_up', to: 'registrations#new'
      get '/reset_password', to: 'passwords#new'

      post '/sign_in', to: 'sessions#create', as: 'session'
      post '/sign_up', to: 'registrations#create', as: 'registration'
    end

    root to: redirect('/users/sign_in', status: 302)
  end

  constraints user_access do
    namespace :users do
      get '/sign_in', to: redirect('/todos/uncompleted', status: 302)

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

    root to: redirect('/todos/uncompleted', status: 302), as: :users_root
  end

  match '/404', to: 'errors#not_found', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
