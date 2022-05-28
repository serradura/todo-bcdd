# frozen_string_literal: true

module User::Repository
  extend self

  def create_user(email:, api_token:, password:)
    ::User::Record.create(
      email: email.value,
      api_token: api_token.value,
      encrypted_password: password.encrypted
    )
  end

  def valid_reset_password_token?(token)
    return false if token.invalid?

    ::User::Record.exists?(reset_password_token: token.value)
  end

  def find_user_by_id(id)
    ::User::Record.find_by(id: id.value)
  end

  def find_user_by_email(email)
    return if email.invalid?

    ::User::Record.find_by(email: email.value)
  end

  def find_user_by_api_token(token)
    return if token.invalid?

    ::User::Record.find_by(api_token: token.value)
  end

  def find_user_by_reset_password_token(token)
    return if token.invalid?

    ::User::Record.find_by(reset_password_token: token.value)
  end

  def update_reset_password_token(email:, token:)
    return false if email.invalid? || token.invalid?

    update(
      conditions: {email: email.value},
      attributes: {reset_password_token: token.value}
    )
  end

  def update_api_token(old_token:, new_token:)
    return false if old_token.invalid? || new_token.invalid?

    update(
      conditions: {api_token: old_token.value},
      attributes: {api_token: new_token.value}
    )
  end

  private

    def update(conditions:, attributes:)
      updated = ::User::Record.where(conditions).update_all(attributes)

      updated == 1
    end
end
