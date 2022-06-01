# frozen_string_literal: true

module User::Repository
  extend self

  AsReadonly = ->(user) { user&.tap(&:readonly!) }

  def create_user(email:, api_token:, password:)
    ::User::Record.create(
      email: email.value,
      api_token: api_token.value,
      encrypted_password: password.encrypted
    ).then(&AsReadonly)
  end

  def valid_reset_password_token?(token)
    return false if token.invalid?

    ::User::Record.exists?(reset_password_token: token.value)
  end

  def find_user_by_id(id)
    find_user_by(id: id.value) if id.valid?
  end

  def find_user_by_email(email)
    find_user_by(email: email.value) if email.valid?
  end

  def find_user_by_api_token(token)
    find_user_by(api_token: token.value) if token.valid?
  end

  def find_user_by_reset_password_token(token)
    find_user_by(reset_password_token: token.value) if token.valid?
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

  def change_user_password(user, password)
    return false unless user.persisted? || password.valid?

    update(
      conditions: {id: user.id},
      attributes: {reset_password_token: nil, encrypted_password: password.encrypted}
    )
  end

  private

    def update(conditions:, attributes:)
      attributes.merge!(updated_at: ::Time.current)

      updated = ::User::Record.where(conditions).update_all(attributes)

      updated == 1
    end

    def find_user_by(conditions)
      ::User::Record.find_by(conditions).then(&AsReadonly)
    end
end
