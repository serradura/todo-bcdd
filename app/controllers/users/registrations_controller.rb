# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    layout 'users/guest'

    def new
      render('users/registrations/new')
    end
  end
end
