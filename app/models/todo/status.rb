# frozen_string_literal: true

module Todo
  class Status < ::Kind::Value
    value_object(with: :validation) do |strategy_to|
      COMPLETED   = :completed
      UNCOMPLETED = :uncompleted

      ALL  = Set[COMPLETED, UNCOMPLETED].freeze
      LIST = (ALL + ALL.map(&:to_s)).freeze

      def strategy_to.normalize(value)
        value.to_sym if value.respond_to?(:to_sym) && LIST.include?(value)
      end

      def strategy_to.validate(value)
        'is invalid' if value.nil?
      end
    end

    def completed? = value == COMPLETED

    def uncompleted? = value == UNCOMPLETED

    private_constant :LIST
  end
end
