# frozen_string_literal: true

module User::APIToken
  class Generate < ::Micro::Case
    attribute :token, validates: {presence: true, length: {is: Value::LENGTH}}

    def call!
      updated = ::User::Record.where(api_token: token).update_all(api_token: Value.generate)

      return Failure(:user_not_found) if updated.zero?

      Success(:api_token_updated)
    end
  end
end
