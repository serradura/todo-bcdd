# frozen_string_literal: true

module Users
  class SessionsController < BaseController
    def new
      request.env.dig('todo_bcdd', :unauthenticated).then do |message|
        flash.now.alert = message if message
      end

      render('users/sessions/new', locals: {user_email: nil})
    end

    def create
      warden.authenticate(:password, scope: :user)

      if warden.authenticated?(:user)
        redirect_to(users_root_url, notice: 'Logged in!')
      else
        flash.now.alert = warden.message

        user_email = params.require(:user).fetch(:email)

        render('users/sessions/new', locals: {user_email:})
      end
    end

    def destroy
      warden.logout(:user)

      redirect_to(root_url, notice: 'Logged out!')
    end
  end
end
