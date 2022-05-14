# frozen_string_literal: true

module Users
  class SessionsController < BaseController
    def new
      render('users/sessions/new')
    end
  end
end
