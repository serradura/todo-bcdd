# frozen_string_literal: true

module User::ResetPassword
  class Process < ::Micro::Case
    TrimmedString = ->(value) { String(value).strip }

    attribute :token, default: ->(value) { Token.new(value) }
    attribute :password, default: TrimmedString
    attribute :password_confirmation, default: TrimmedString

    def call!
      return Failure(:invalid_token) unless token.valid?

      errors = {}
      errors[:password] = "can't be blank" if password.blank?
      errors[:password] ||= 'is too short (minimum: 6)' if password.size < 6
      errors[:password_confirmation] = "can't be blank" if password_confirmation.blank?
      errors[:password_confirmation] ||= "doesn't match password" if password != password_confirmation

      return Failure(:invalid_password, result: {errors:}) if errors.present?

      user = ::User::Record.find_by(reset_password_token: token.value)

      return Failure(:user_not_found) unless user

      encrypted_password = ::BCrypt::Password.create(password)

      user.update!(encrypted_password:, reset_password_token: nil)

      Success :user_password_changed, result: {user:}
    end
  end
end
