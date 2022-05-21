# frozen_string_literal: true

module User
  class Authentication::GetById < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}

    def call!
      user = Record.find_by(id:)

      return Failure(:user_not_found) unless user

      Success :user_found, result: {user:}
    end
  end
end
