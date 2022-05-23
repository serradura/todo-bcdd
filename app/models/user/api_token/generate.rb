# frozen_string_literal: true

module User::APIToken
  class Generate < ::Micro::Case
    attribute :token, validates: {presence: true, length: {is: Value::LENGTH}}

    def call!
      api_token = Value.new

      updated = ::User::Record.where(api_token: token).update_all(api_token: api_token.value)

      return Failure(:user_not_found) if updated.zero?

      Success(:api_token_updated)
    end
  end
end
