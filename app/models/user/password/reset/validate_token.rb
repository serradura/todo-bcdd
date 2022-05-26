# frozen_string_literal: true

class User::Password::Reset
  class ValidateToken < ::Micro::Case
    attribute :token, default: ->(value) { Token.new(value) }
    attribute :repository, {
      default: ::User::Repository,
      validates: {kind: {respond_to: :valid_reset_password_token?}}
    }

    def call!
      valid_token = repository.valid_reset_password_token?(token)

      valid_token ? Success(:valid_token) : Failure(:invalid_token)
    end
  end
end
