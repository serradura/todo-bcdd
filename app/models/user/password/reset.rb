# frozen_string_literal: true

class User::Password::Reset < ::Micro::Case
  attribute :token, default: proc(&Token)
  attribute :password, default: proc(&::User::Password)
  attribute :password_confirmation, default: proc(&::User::Password)
  attribute :repository, {
    default: ::User::Repository,
    validates: {kind: {respond_to: :find_user_by_api_token}}
  }

  def call!
    return Failure(:invalid_token) unless token.valid?

    errors = ::User::Password::ValidateWithConfirmation.call(password, password_confirmation)

    return Failure(:invalid_password, result: {errors:}) if errors.present?

    user = repository.find_user_by_reset_password_token(token)

    return Failure(:user_not_found) unless user

    user.update!(reset_password_token: nil, encrypted_password: password.encrypted)

    Success :user_password_changed, result: {user:}
  end
end
