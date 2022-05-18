# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

    def warden
      request.env['warden']
    end

    def current_user
      warden.user(:user)
    end

    def authenticate_user!
      warden.authenticate!(:password, scope: :user)
    end
end
