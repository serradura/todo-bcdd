# frozen_string_literal: true

class User::Password::Reset
  class ValidateToken < ::Micro::Case
    attribute :token, default: ->(value) { String(value).strip }

    def call!
      return Failure(:invalid_token) unless Token.valid?(token)

      return Failure(:user_not_found) unless ::User::Record.exists?(reset_password_token: token)

      Success(:valid_token)
    end
  end
end
