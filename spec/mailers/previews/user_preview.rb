# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  EMAIL = 'email@example.com'

  def welcome
    ::UserMailer.with(email: EMAIL).welcome
  end

  def reset_password
    reset_password_token = ::SecureRandom.uuid

    ::UserMailer.with(reset_password_token:, email: EMAIL).reset_password
  end
end
