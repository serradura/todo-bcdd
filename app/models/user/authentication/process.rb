# frozen_string_literal: true

class User::Authentication::Process < ::Micro::Case
  TrimmedString = ->(value) { String(value).strip }

  attribute :email, default: TrimmedString >> lambda(&:downcase)
  attribute :password, default: TrimmedString

  def call!
    user = ::User.find_by(email:)

    return Failure(:user_not_found) unless user

    return Failure(:invalid_password) if ::BCrypt::Password.new(user.encrypted_password) != password

    Success :user_found, result: {user:}
  end
end
