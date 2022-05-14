# frozen_string_literal: true

module Users
  class PasswordsController < BaseController
    def new
      render('users/passwords/new')
    end
  end
end
