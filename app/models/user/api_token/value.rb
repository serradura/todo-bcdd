# frozen_string_literal: true

class User::APIToken::Value < Kind::Value
  value_object(with: :validation) do |strategy_to|
    strategy_to.generate_default_for_nil_inputs = false

    LENGTH = 36

    def strategy_to.generate_default_value
      ::SecureRandom.base58(LENGTH)
    end

    def strategy_to.normalize(input) = String(input).strip

    def strategy_to.validate(input)
      return if input.size == LENGTH

      "is the wrong length (should be #{LENGTH} characters)"
    end
  end
end
