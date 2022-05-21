# frozen_string_literal: true

module User
  class RegisterAndSendWelcomeEmail < ::Micro::Case
    attribute :email, default: ->(value) { ::User::Email.new(value) }
    attribute :password, default: ->(value) { ::User::Password.new(value) }
    attribute :password_confirmation, default: ->(value) { ::User::Password.new(value) }

    def call!
      errors = {}

      errors[:email] = email.validation_error if email.invalid?

      errors.merge!(::User::Password.validate(password:, confirmation: password_confirmation))

      return failure_with_validation(errors:) if errors.present?

      api_token = APIToken::Value.generate

      user = Record.new(api_token:, email: email.value, encrypted_password: password.encrypted)

      if user.save
        ::User::Mailer.with(email: email.value).welcome.deliver_later

        Success :user_created, result: {user:}
      else
        errors = user.errors.messages.transform_values { |messages| messages.join(', ') }

        failure_with_validation(errors:)
      end
    end

    private

      def failure_with_validation(errors:)
        Failure :validation_errors, result: {errors:, email: email.value}
      end
  end
end
