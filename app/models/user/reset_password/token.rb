# frozen_string_literal: true

require 'kind_value'

class User::ResetPassword::Token < Kind::Value
  include Kind::Value::Validation

  def self.call_to_generate_a_default_value = ::SecureRandom.uuid

  def self.call_to_normalize_the_value(input) = String(input).strip

  FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

  def self.call_to_validate_the_value(value)
    'must be an UUID' unless value.match?(FORMAT)
  end
end
