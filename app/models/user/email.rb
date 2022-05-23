# frozen_string_literal: true

require 'kind_value'

class User::Email < Kind::Value
  def self.call_to_normalize_the_value(input) = String(input).strip.downcase

  attr_reader :validation_error

  FORMAT = ::URI::MailTo::EMAIL_REGEXP

  def invalid?
    @validation_error = 'is invalid' unless value.present? && value.match?(FORMAT)
    @validation_error.present?
  end

  def valid? = !invalid?
end
