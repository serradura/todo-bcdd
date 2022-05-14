# frozen_string_literal: true

module Users
  class SessionsController < BaseController
    def new
      render('users/sessions/new')
    end

    def create
      warden.authenticate(:password, scope: :user)

      if warden.authenticated?(:user)
        redirect_to(users_root_url, notice: 'Logged in!')
      else
        render('users/sessions/new', alert: warden.message)
      end
    end

    def destroy
      warden.logout(:user)

      redirect_to(root_url, notice: 'Logged out!')
    end
  end
end
