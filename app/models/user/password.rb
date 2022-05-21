# frozen_string_literal: true

class User::Password
  def self.validate(password:, confirmation:)
    errors = {}
    errors[:password] = password.validation_error if password.invalid?
    errors[:password_confirmation] = confirmation.validation_error if confirmation.invalid?
    errors[:password_confirmation] ||= "doesn't match password" if password != confirmation
    errors
  end

  attr_reader :value, :validation_error

  def initialize(object)
    @value = object.is_a?(self.class) ? object.value : String(object).strip
    @validation_error = nil
  end

  MINIMUM = 6

  def invalid?
    @validation_error = "can't be blank" if value.blank?
    @validation_error ||= "is too short (minimum: #{MINIMUM})" if value.size < MINIMUM
    @validation_error.present?
  end

  def ==(other)
    other.is_a?(self.class) && value == other.value
  end

  def encrypted
    @encrypted ||= ::BCrypt::Password.create(value)
  end
end
