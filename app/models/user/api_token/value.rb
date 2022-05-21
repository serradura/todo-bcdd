# frozen_string_literal: true

module User::APIToken
  module Value
    LENGTH = 36

    def self.generate
      ::SecureRandom.base58(LENGTH)
    end
  end
end
