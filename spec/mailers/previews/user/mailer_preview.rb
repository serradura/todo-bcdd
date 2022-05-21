# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user
class User::MailerPreview < ActionMailer::Preview
  EMAIL = 'email@example.com'

  def welcome
    ::User::Mailer.with(email: EMAIL).welcome
  end

  def reset_password
    reset_password_token = ::SecureRandom.uuid

    ::User::Mailer.with(reset_password_token:, email: EMAIL).reset_password
  end
end
