# frozen_string_literal: true

class User::Password::Reset < ::Micro::Case
  attribute :token, default: proc(&::Kind::UUID)
  attribute :password, default: proc(&::User::Password)
  attribute :password_confirmation, default: proc(&::User::Password)
  attribute :repository, {
    default: ::User::Repository,
    validates: {kind: {respond_to: [:find_user_by_reset_password_token, :change_user_password]}}
  }

  def call!
    validate_token
      .then(:validate_password_with_confirmation)
      .then(:find_user_by_reset_password_token)
      .then(:update_user_password)
  end

  private

    def validate_token = token.valid? ? Success(:valid_token) : Failure(:invalid_token)

    def validate_password_with_confirmation
      errors = ::User::Password::ValidateWithConfirmation.call(password, password_confirmation)

      errors.empty? ? Success(:valid_password) : Failure(:invalid_password, result: {errors:})
    end

    def find_user_by_reset_password_token
      user = repository.find_user_by_reset_password_token(token)

      user ? Success(result: {user:}) : Failure(:user_not_found)
    end

    def update_user_password(user:, **)
      password_changed = repository.change_user_password(user, password)

      raise NotImplementedError unless password_changed

      Success :user_password_changed, result: {user:}
    end
end
