# frozen_string_literal: true

module User::APIToken
  class Generate < ::Micro::Case
    attribute :token, default: proc(&Value)
    attribute :repository, {
      default: ::User::Repository,
      validates: {kind: {respond_to: :update_api_token}}
    }

    def call!
      return Failure(:invalid_token) if token.invalid?

      updated = repository.update_api_token(old_token: token, new_token: Value.new)

      updated ? Success(:api_token_updated) : Failure(:user_not_found)
    end
  end
end
