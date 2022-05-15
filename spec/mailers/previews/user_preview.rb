# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def welcome
    user = ::User.new(email: 'email@example.com')

    ::UserMailer.with(user: user).welcome
  end
end
