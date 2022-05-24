# frozen_string_literal: true

require 'kind_value'

class User::Password < Kind::Value
  value_object(with: :validation) do |strategy_to|
    def strategy_to.normalize(input) = String(input).strip

    MINIMUM = 6

    def strategy_to.validate(value)
      return "can't be blank" if value.blank?

      "is too short (minimum: #{MINIMUM})" if value.size < MINIMUM
    end
  end

  def self.match?(encrypted, password)
    ::BCrypt::Password.new(encrypted) == value(password)
  end

  def encrypted
    @encrypted ||= ::BCrypt::Password.create(value)
  end
end
