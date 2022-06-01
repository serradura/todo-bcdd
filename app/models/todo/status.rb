# frozen_string_literal: true

module Todo
  class Status < ::Kind::Value
    value_object(with: :validation) do |strategy_to|
      COMPLETED   = :completed
      UNCOMPLETED = :uncompleted

      ALL   = Set[COMPLETED, UNCOMPLETED].freeze
      NAMES = ALL.flat_map { [_1, _1.to_s] }.to_set.freeze

      def strategy_to.normalize(value)
        value.to_sym if NAMES.include?(value)
      end

      def strategy_to.validate(value)
        'is invalid' if value.nil?
      end
    end

    def completed? = value == COMPLETED

    def uncompleted? = value == UNCOMPLETED

    private_constant :NAMES
  end
end
