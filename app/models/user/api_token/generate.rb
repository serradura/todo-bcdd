# frozen_string_literal: true

class User::APIToken::Generate < ::Micro::Case
  attribute :token, validates: {presence: true, length: {is: 36}}

  def call!
    new_api_token = SecureRandom.base58(36)

    updated = ::User.where(api_token: token).update_all(api_token: new_api_token)

    return Failure(:user_not_found) if updated.zero?

    Success(:api_token_updated)
  end
end
