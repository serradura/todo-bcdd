# frozen_string_literal: true

require 'kind_value'

class User::APIToken::Value < Kind::Value
  value_object do |strategy_to|
    LENGTH = 36

    def strategy_to.generate_default_value
      ::SecureRandom.base58(LENGTH)
    end
  end
end
