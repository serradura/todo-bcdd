# frozen_string_literal: true

module User
  class APIToken::Authenticate < ::Micro::Case
    attribute :token, validates: {presence: true, length: {is: 36}}

    def call!
      user = Record.find_by(api_token: token)

      return Failure(:user_not_found) unless user

      Success :user_found, result: {user:}
    end
  end
end
