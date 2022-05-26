# frozen_string_literal: true

module User
  class Authentication::GetById < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :repository, {
      default: ::User::Repository,
      validates: {kind: {respond_to: :find_user_by_id}}
    }

    def call!
      user = repository.find_user_by_id(id)

      return Failure(:user_not_found) unless user

      Success :user_found, result: {user:}
    end
  end
end
