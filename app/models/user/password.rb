# frozen_string_literal: true

require 'kind_value'

class User::Password < Kind::Value
  def self.call_to_normalize_the_value(input) = String(input).strip

  def self.match?(encrypted, password) = ::BCrypt::Password.new(encrypted) == value(password)

  def self.validate(password:, confirmation:)
    errors = {}
    errors[:password] = password.validation_error if password.invalid?
    errors[:password_confirmation] = confirmation.validation_error if confirmation.invalid?
    errors[:password_confirmation] ||= "doesn't match password" if password != confirmation
    errors
  end

  attr_reader :validation_error

  MINIMUM = 6

  def invalid?
    @validation_error = "can't be blank" if value.blank?
    @validation_error ||= "is too short (minimum: #{MINIMUM})" if value.size < MINIMUM
    @validation_error.present?
  end

  def encrypted = @encrypted ||= ::BCrypt::Password.create(value)

  def present? = value.present?
end
