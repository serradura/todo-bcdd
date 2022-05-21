# frozen_string_literal: true

module User::APIToken
  class Authenticate < ::Micro::Case
    attribute :token, validates: {presence: true, length: {is: Value::LENGTH}}

    def call!
      user = ::User::Record.find_by(api_token: token)

      return Failure(:user_not_found) unless user

      Success :user_found, result: {user:}
    end
  end
end
