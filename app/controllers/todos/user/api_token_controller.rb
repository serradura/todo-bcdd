# frozen_string_literal: true

module Todos::User
  class APITokenController < ::Todos::BaseController
    def update
      notice =
        ::User::GenerateNewAPIToken.call(token: params[:token]) do |on|
          on.success { 'Your new API token was successfully generated' }
          on.failure { 'Cannot generate a new API token because the given one is invalid' }
        end

      redirect_to(todos_user_account_path, notice:)
    end
  end
end
