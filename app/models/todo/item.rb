# frozen_string_literal: true

module Todo
  module Item
    Struct = ::Micro::Struct.immutable.new(
      :id,
      :description,
      :completed_at,
      :created_at,
      :updated_at
    ) do
      def status = @status ||= uncompleted? ? Status::UNCOMPLETED : Status::COMPLETED

      def completed? = !uncompleted?

      def uncompleted? = completed_at.nil?
    end

    def self.new(id:, description:, completed_at:, created_at:, updated_at:)
      Struct.new(id:, description:, completed_at:, created_at:, updated_at:)
    end

    def self.===(object)
      Struct === object
    end

    private_constant :Struct
  end
end
