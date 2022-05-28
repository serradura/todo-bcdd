# frozen_string_literal: true

require 'kind'

module Kind
  class Value
    require_relative 'value/strategy'
    require_relative 'value/validation'

    def self.value_object(with: nil)
      mod = ::Module.new
      mod.extend(::Kind::Value::Strategy)
      mod.generate_default_for_nil_inputs = true
      mod.instance_variable_set(:@value_class, self)

      if with == :validation
        include(Validation)

        extend(Validation::Macros)

        mod.extend(Validation::Strategy)
      end

      yield(mod)

      const_set(:Strategy, mod)
    end

    def self.strategy_to
      @strategy_to ||= const_get(:Strategy, false)
    end

    def self.value(input)
      input.is_a?(self) ? input.value : strategy_to.normalize(input)
    end

    def self.new(input = ::Kind::Undefined)
      return input if input.is_a?(self.class)

      value =
        if ::Kind::Undefined == input || (input.nil? && strategy_to.generate_default_for_nil_inputs)
          strategy_to.generate_default_value
        else
          input
        end

      instance = allocate
      instance.send(:initialize, value)
      instance
    end

    def self.to_proc
      @to_proc ||= ->(value = ::Kind::Undefined) { new(value) }
    end

    attr_reader :value

    def initialize(value)
      @value = self.class.strategy_to.normalize(value)

      call_after_the_initialization
    end

    def ==(other)
      other.is_a?(self.class) && value == other.value
    end

    def blank?
      return value.blank? if value.respond_to?(:blank?)

      raise NotImplementedError
    end

    def present?
      !blank?
    end

    def nil?
      value.nil?
    end

    private

      def call_after_the_initialization
      end
  end
end
