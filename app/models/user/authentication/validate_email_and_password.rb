# frozen_string_literal: true

class User::Authentication::ValidateEmailAndPassword < ::Micro::Case
  TrimmedString = ->(value) { String(value).strip }

  attribute :email, default: TrimmedString
  attribute :password, default: TrimmedString

  def call!
    valid_email = email.present? && ::URI::MailTo::EMAIL_REGEXP.match?(email)

    return Success(:valid_email_and_password) if valid_email && password.present?

    Failure(:invalid_email_or_password)
  end
end
