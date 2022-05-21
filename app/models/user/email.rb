# frozen_string_literal: true

class User::Email
  attr_reader :value, :validation_error

  def initialize(object)
    @value = object.is_a?(self.class) ? object.value : String(object).strip.downcase
  end

  FORMAT = ::URI::MailTo::EMAIL_REGEXP

  def invalid?
    @validation_error = 'is invalid' unless value.present? && value.match?(FORMAT)
    @validation_error.present?
  end

  def valid?
    !invalid?
  end
end
