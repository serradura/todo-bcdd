# frozen_string_literal: true

class User::ValidateResetPasswordToken < ::Micro::Case
  attribute :token, default: ->(value) { String(value).strip }

  UUID_FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

  def call!
    return Failure(:invalid_token) unless UUID_FORMAT.match?(token)

    return Failure(:user_not_found) unless ::User.exists?(reset_password_token: token)

    Success(:valid_token)
  end
end
