# frozen_string_literal: true

require 'kind_value'

class User::APIToken::Value < Kind::Value
  LENGTH = 36

  def self.call_to_generate_a_default_value
    ::SecureRandom.base58(LENGTH)
  end
end
