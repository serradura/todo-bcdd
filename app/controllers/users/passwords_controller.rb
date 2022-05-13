# frozen_string_literal: true

module Users
  class PasswordsController < ApplicationController
    layout 'users/guest'

    def new
      render('users/passwords/new')
    end
  end
end
