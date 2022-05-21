# frozen_string_literal: true

module User
  class RegisterAndSendWelcomeEmail < ::Micro::Case
    TrimmedString = ->(value) { String(value).strip }

    attribute :email, default: TrimmedString >> lambda(&:downcase)
    attribute :password, default: ->(value) { ::User::Password.new(value) }
    attribute :password_confirmation, default: ->(value) { ::User::Password.new(value) }

    def call!
      errors = {}
      errors[:email] = 'is invalid' if email.blank? || !::URI::MailTo::EMAIL_REGEXP.match?(email)

      errors.merge! ::User::Password.validate(password:, confirmation: password_confirmation)

      return failure_with_validation(errors:) if errors.present?

      api_token = APIToken::Value.generate

      user = Record.new(email:, api_token:, encrypted_password: password.encrypted)

      if user.save
        ::User::Mailer.with(email:).welcome.deliver_later

        Success :user_created, result: {user:}
      else
        errors = user.errors.messages.transform_values { |messages| messages.join(', ') }

        failure_with_validation(errors:)
      end
    end

    private

      def failure_with_validation(errors:)
        Failure :validation_errors, result: {email:, errors:}
      end
  end
end
