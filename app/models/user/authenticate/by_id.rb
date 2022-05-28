# frozen_string_literal: true

class User::Authenticate::ById < ::Micro::Case
  attribute :id, default: proc(&::Kind::ID)
  attribute :repository, {
    default: ::User::Repository,
    validates: {kind: {respond_to: :find_user_by_id}}
  }

  def call!
    return Failure(:invalid_id) if id.invalid?

    user = repository.find_user_by_id(id)

    return Failure(:user_not_found) unless user

    Success(:user_found, result: {user:})
  end
end
