# frozen_string_literal: true

class API::V1::BaseController < ActionController::API
  private

    def warden
      request.env['warden']
    end

    def authenticate_user!
      warden.authenticate!(:api_token, scope: :api_v1)
    end

    def current_user
      warden.user(:api_v1)
    end
end
