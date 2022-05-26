# frozen_string_literal: true

module User::APIToken
  class Authenticate < ::Micro::Case
    attribute :token, default: ->(value) { Value.new(value) }
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
end
