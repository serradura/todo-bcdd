# frozen_string_literal: true

class User::Password::Reset
  class SendInstructions < ::Micro::Case
    attribute :email, default: proc(&::User::Email)
    attribute :repository, {
      default: ::User::Repository,
      validates: {kind: {respond_to: :update_reset_password_token}}
    }

    def call!
      validate_email
        .then(:update_reset_password_token)
        .then(:send_instructions_by_email)
    end

    private

      def validate_email = email.valid? ? Success(:valid_email) : Failure(:invalid_email)

      def update_reset_password_token
        token = ::Kind::UUID.new

        updated = repository.update_reset_password_token(email:, token:)

        updated ? Success(:user_updated, result: {token:}) : Failure(:user_not_found)
      end

      def send_instructions_by_email(token:, **)
        mailer_params = {email: email.value, reset_password_token: token.value}

        ::User::Mailer.with(mailer_params).reset_password.deliver_later

        Success(:instructions_delivered)
      end
  end
end
