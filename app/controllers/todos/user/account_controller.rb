# frozen_string_literal: true

module Todos::User
  class AccountController < ::Todos::BaseController
    def show
      render 'todos/user/account', locals: {
        user_email: current_user.email,
        user_api_token: current_user.api_token,
        api_base_url: "#{request.base_url}/api/v1"
      }
    end
  end
end
