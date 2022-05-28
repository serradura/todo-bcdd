# frozen_string_literal: true

require 'securerandom'

require_relative 'value'

class Kind::UUID < ::Kind::Value
  value_object(with: :validation) do |strategy_to|
    strategy_to.generate_default_for_nil_inputs = false

    def strategy_to.generate_default_value = ::SecureRandom.uuid

    def strategy_to.normalize(input) = String(input).strip

    FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

    def strategy_to.validate(value)
      'must be an UUID' unless value.is_a?(::String) && value.match?(FORMAT)
    end
  end
end
