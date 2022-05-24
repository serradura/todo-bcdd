# frozen_string_literal: true

require 'kind_value'

class User::Email < Kind::Value
  include Kind::Value::Validation

  def self.call_to_normalize_the_value(input)
    String(input).strip.downcase
  end

  FORMAT = ::URI::MailTo::EMAIL_REGEXP

  def self.call_to_validate_the_value(value)
    'is invalid' unless value.present? && value.match?(FORMAT)
  end
end
