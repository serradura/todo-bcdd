# frozen_string_literal: true

module User::ResetPassword
  class Process < ::Micro::Case
    attribute :token, default: ->(value) { Token.new(value) }
    attribute :password, default: ->(value) { ::User::Password.new(value) }
    attribute :password_confirmation, default: ->(value) { ::User::Password.new(value) }

    def call!
      return Failure(:invalid_token) unless token.valid?

      errors = ::User::Password::ValidateWithConfirmation.call(password, password_confirmation)

      return Failure(:invalid_password, result: {errors:}) if errors.present?

      user = ::User::Record.find_by(reset_password_token: token.value)

      return Failure(:user_not_found) unless user

      user.update!(reset_password_token: nil, encrypted_password: password.encrypted)

      Success :user_password_changed, result: {user:}
    end
  end
end
