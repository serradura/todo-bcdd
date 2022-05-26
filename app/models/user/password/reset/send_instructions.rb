# frozen_string_literal: true

class User::Password::Reset
  class SendInstructions < ::Micro::Case
    attribute :email, default: proc(&::User::Email)
    attribute :repository, {
      default: ::User::Repository,
      validates: {kind: {respond_to: :update_reset_password_token}}
    }

    def call!
      return Failure(:invalid_email) if email.invalid?

      token = Token.new

      updated = repository.update_reset_password_token(email:, token:)

      return Failure(:user_not_found) unless updated

      mailer_params = {email: email.value, reset_password_token: token.value}

      ::User::Mailer.with(mailer_params).reset_password.deliver_later

      Success(:instructions_delivered)
    end
  end
end
