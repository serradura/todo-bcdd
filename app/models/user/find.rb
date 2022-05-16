# frozen_string_literal: true

class User::Find < ::Micro::Case
  attribute :id, validates: {numericality: {only_integer: true}}

  def call!
    user = ::User.find_by(id:)

    return Failure(:user_not_found) unless user

    Success :user_found, result: {user:}
  end
end
