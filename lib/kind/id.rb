# frozen_string_literal: true

require_relative 'value'

class Kind::ID < ::Kind::Value
  value_object(with: :validation) do |strategy_to|
    FORMAT = /\A\d+\z/

    def strategy_to.normalize(input)
      return input if input.is_a?(::Integer)

      return input.to_i if input.is_a?(String) && !input.empty? && input.match?(FORMAT)
    end

    def strategy_to.validate(value)
      'must be a positive integer' unless value.is_a?(::Integer) && value.positive?
    end
  end
end
