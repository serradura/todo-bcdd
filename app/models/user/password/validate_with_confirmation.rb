# frozen_string_literal: true

require 'kind_value'

module User::Password::ValidateWithConfirmation
  def self.call(password, confirmation)
    errors = {}
    errors[:password] = password.validation_error if password.invalid?
    errors[:password_confirmation] = confirmation.validation_error if confirmation.invalid?
    errors[:password_confirmation] ||= "doesn't match password" if password != confirmation
    errors
  end
end
