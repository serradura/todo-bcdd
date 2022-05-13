# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    layout 'users/guest'

    def new
      render('users/sessions/new')
    end
  end
end
