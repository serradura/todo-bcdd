# frozen_string_literal: true

class User::SendInstructionsToResetPassword < ::Micro::Case
  attribute :email, {
    default: ->(value) { String(value).strip.downcase },
    validates: {format: ::URI::MailTo::EMAIL_REGEXP}
  }

  def call!
    reset_password_token = ::SecureRandom.uuid

    updated = ::User.where(email:).update_all(reset_password_token:)

    return Failure(:user_not_found) if updated.zero?

    ::UserMailer.with(email:, reset_password_token:).reset_password.deliver_later

    Success(:instructions_delivered)
  end
end
