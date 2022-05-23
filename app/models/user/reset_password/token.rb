# frozen_string_literal: true

require 'kind_value'

class User::ResetPassword::Token < Kind::Value
  def self.call_to_generate_a_default_value = ::SecureRandom.uuid

  def self.call_to_normalize_the_value(input) = String(input).strip

  FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

  def self.valid?(input) = value(input).match?(FORMAT)

  def valid? = self.class.valid?(self)
end
