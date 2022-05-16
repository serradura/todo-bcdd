# frozen_string_literal: true

class User::CreateAndSendWelcomeEmail < ::Micro::Case
  TrimmedString = ->(value) { String(value).strip }

  attribute :email, default: TrimmedString >> lambda(&:downcase)
  attribute :password, default: TrimmedString
  attribute :password_confirmation, default: TrimmedString

  def call!
    errors = {}
    errors[:email] = 'is invalid' if email.blank? || !::URI::MailTo::EMAIL_REGEXP.match?(email)
    errors[:password] = "can't be blank" if password.blank?
    errors[:password] ||= 'is too short (minimum: 6)' if password.size < 6
    errors[:password_confirmation] = "can't be blank" if password_confirmation.blank?
    errors[:password_confirmation] ||= "doesn't match password" if password != password_confirmation

    return failure_with_validation(errors:) if errors.present?

    encrypted_password = ::BCrypt::Password.create(password)

    user = ::User.new(email:, encrypted_password:)

    if user.save
      ::UserMailer.with(email:).welcome.deliver_later

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
