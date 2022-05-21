# frozen_string_literal: true

class User::APIToken::Authenticate < ::Micro::Case
  attribute :token, validates: {presence: true, length: {is: 36}}

  def call!
    user = ::User.find_by(api_token: token)

    return Failure(:user_not_found) unless user

    Success :user_found, result: {user:}
  end
end
