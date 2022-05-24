# frozen_string_literal: true

require 'kind_value'

class User::Password < Kind::Value
  include Kind::Value::Validation

  def self.call_to_normalize_the_value(input)
    String(input).strip
  end

  MINIMUM = 6

  def self.call_to_validate_the_value(value)
    return "can't be blank" if value.blank?

    "is too short (minimum: #{MINIMUM})" if value.size < MINIMUM
  end

  def self.match?(encrypted, password) = ::BCrypt::Password.new(encrypted) == value(password)

  def encrypted = @encrypted ||= ::BCrypt::Password.create(value)
end
