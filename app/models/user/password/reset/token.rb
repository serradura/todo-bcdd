# frozen_string_literal: true

class User::Password::Reset
  class Token < Kind::Value
    value_object(with: :validation) do |strategy_to|
      def strategy_to.generate_default_value = ::SecureRandom.uuid

      def strategy_to.normalize(input) = String(input).strip

      FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

      def strategy_to.validate(value)
        'must be an UUID' unless value.match?(FORMAT)
      end
    end
  end
end
