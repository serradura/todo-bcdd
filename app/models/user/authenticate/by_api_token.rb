# frozen_string_literal: true

class User::Authenticate::ByAPIToken < ::Micro::Case
  attribute :token, default: proc(&::User::APIToken::Value)
  attribute :repository, {
    default: ::User::Repository,
    validates: {kind: {respond_to: :find_user_by_api_token}}
  }

  def call!
    user = repository.find_user_by_api_token(token)

    return Failure(:invalid_token) unless user

    Success :user_found, result: {user:}
  end
end
