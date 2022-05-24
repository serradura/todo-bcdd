# frozen_string_literal: true

module Kind::Value::Validation
  module Macros
    def call_to_validate_the_value(_value)
      raise NotImplementedError
    end

    def call_to_validate_the_value!(value)
      output = call_to_validate_the_value(value)

      return output if output.nil? || output.respond_to?(:to_sym)

      raise ArgumentError.new("#{self.class}.call_to_validate_the_value(arg) must return nil, String or Symbol")
    end

    def valid?(input)
      call_to_validate_the_value!(value(input)).nil?
    end
  end

  def self.included(base)
    base.extend(Macros)

    base.send(:attr_reader, :validation_error)
  end

  def validation_error?
    !validation_error.nil?
  end

  def invalid?
    @validation_error = self.class.call_to_validate_the_value!(value)

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
