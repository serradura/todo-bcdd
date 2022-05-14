# frozen_string_literal: true

module Users
  class RegistrationsController < BaseController
    def new
      render('users/registrations/new')
    end
  end
end
