# frozen_string_literal: true

module User
  class RegisterAndSendWelcomeEmail < ::Micro::Case
    attribute :email, default: ->(value) { ::User::Email.new(value) }
    attribute :password, default: ->(value) { ::User::Password.new(value) }
    attribute :password_confirmation, default: ->(value) { ::User::Password.new(value) }
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :create_user}}
    }

    def call!
      validate_email_and_passwords
        .then(:create_user)
        .then(:send_welcome_email)
        .then_expose(user_registered: [:user])
    end

    private

      def failure_with_validation(errors:)
        Failure :validation_errors, result: {errors:, email: email.value}
      end

      def validate_email_and_passwords
        errors = ::User::Password::ValidateWithConfirmation.call(password, password_confirmation)

        errors[:email] = email.validation_error if email.invalid?

        return failure_with_validation(errors:) if errors.present?

        Success(:valid_email_and_passwords)
      end

      def create_user(**)
        api_token = APIToken::Value.new

        user = repository.create_user(email:, api_token:, password:)

        return Success(:user_created, result: {user:}) if user.id?

        errors = user.errors.messages.transform_values { |messages| messages.join(', ') }

        failure_with_validation(errors:)
      end

      def send_welcome_email(**)
        ::User::Mailer.with(email: email.value).welcome.deliver_later

        Success(:email_sent)
      end
  end
end
