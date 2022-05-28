# frozen_string_literal: true

module Kind
  class Value
    module Strategy
      def generate_default_for_nil_inputs=(bool)
        @generate_default_for_nil_inputs = bool
      end

      def generate_default_for_nil_inputs
        @generate_default_for_nil_inputs
      end

      def generate_default_value
        nil
      end

      def normalize(input)
        input
      end

      private

        def value_class
          @value_class
        end
    end
  end
end
