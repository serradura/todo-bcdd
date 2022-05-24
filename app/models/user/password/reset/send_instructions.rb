# frozen_string_literal: true

class User::Password::Reset
  class SendInstructions < ::Micro::Case
    attribute :email, default: ->(value) { ::User::Email.new(value) }

    def call!
      return Failure(:invalid_email) if email.invalid?

      reset_password_token = Token.new.value

      updated = ::User::Record.where(email: email.value).update_all(reset_password_token:)

      return Failure(:user_not_found) if updated.zero?

      ::User::Mailer.with(email: email.value, reset_password_token:).reset_password.deliver_later

      Success(:instructions_delivered)
    end
  end
end
