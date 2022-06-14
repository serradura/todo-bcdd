# frozen_string_literal: true

class Micro::Case::Result
  module ToYieldBuilder
    def to_yield(**kargs)
      ::Micro::Case::Result::Wrapper.new(new(**kargs))
    end
  end

  module Success
    extend ToYieldBuilder

    def self.new(data: {}, type: :ok, use_case: Micro::Case.send(:new, {}))
      instance = ::Micro::Case::Result.new
      instance.__set__(true, data, type, use_case)
      instance
    end
  end

  module Failure
    extend ToYieldBuilder

    def self.new(data: {}, type: :error, use_case: Micro::Case.send(:new, {}))
      instance = ::Micro::Case::Result.new
      instance.__set__(false, data, type, use_case)
      instance
    end
  end
end
