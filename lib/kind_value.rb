# frozen_string_literal: true

module Kind
  class Value
    def self.call_to_generate_a_default_value
      nil
    end

    def self.call_to_normalize_the_value(input)
      input
    end

    def self.value(input)
      input.is_a?(self) ? input.value : call_to_normalize_the_value(input)
    end

    def self.new(input = nil)
      return input if input.is_a?(self.class)

      value = input.nil? ? call_to_generate_a_default_value : input

      instance = allocate
      instance.send(:initialize, value)
      instance
    end

    attr_reader :value

    def initialize(value)
      @value = self.class.call_to_normalize_the_value(value)
    end

    def ==(other)
      other.is_a?(self.class) && value == other.value
    end
  end
end
