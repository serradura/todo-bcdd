# frozen_string_literal: true

class Kind::Value
  module Validation
    module Strategy
      def validate(_value)
        raise NotImplementedError
      end

      def validate!(value)
        output = validate(value)

        return output if output.nil? || output.respond_to?(:to_sym)

        raise ArgumentError.new("#{value_class}.strategy_to.validate(arg) must return nil, String or Symbol")
      end
    end

    module Macros
      def valid?(input)
        strategy_to.validate!(value(input)).nil?
      end
    end

    def self.included(base)
      base.send(:attr_reader, :validation_error)
    end

    def validation_error?
      !validation_error.nil?
    end

    def invalid?
      @validation_error = self.class.strategy_to.validate!(value)

      validation_error?
    end

    def valid?
      !invalid?
    end

    private

      def call_after_the_initialization
        @validation_error = nil
      end
  end

  private_constant :Validation
end
