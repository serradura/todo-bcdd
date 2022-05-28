# frozen_string_literal: true

module Todo
  class Description < ::Kind::Value
    value_object(with: :validation) do |strategy_to|
      def strategy_to.normalize(input) = String(input).strip

      def strategy_to.validate(value)
        "can't be blank" if value.empty?
      end
    end
  end
end
