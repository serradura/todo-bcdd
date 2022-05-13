Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :users do
    get '/reset_password', to: 'passwords#new'
    get '/sign_up', to: 'registrations#new'
    get '/sign_in', to: 'sessions#new'
  end

  root 'users/sessions#new'
end
