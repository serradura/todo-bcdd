# frozen_string_literal: true

class User::Authenticate::ByEmailAndPassword < ::Micro::Case
  attribute :email, default: proc(&::User::Email)
  attribute :password, default: proc(&::User::Password)
  attribute :repository, {
    default: ::User::Repository,
    validates: {kind: {respond_to: :find_user_by_email}}
  }

  def call!
    user = repository.find_user_by_email(email)

    return Failure(:user_not_found) unless user

    return Failure(:invalid_password) if invalid_password?(user)

    Success(:user_found, result: {user:})
  end

  private

    def invalid_password?(user)
      !::User::Password.match?(user.encrypted_password, password)
    end
end
