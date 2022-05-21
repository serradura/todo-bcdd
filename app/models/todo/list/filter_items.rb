# frozen_string_literal: true

module Todo
  module List
    class FilterItems < ::Micro::Case
      attribute :status, validates: {inclusion: {in: Status::ALL}}
      attribute :user_id, validates: {numericality: {only_integer: true}}

      def call!
        relation = status == Status::COMPLETED ? Item::Record.completed : Item::Record.uncompleted

        Success :todos_filtered, result: {todos: relation.where(user_id:)}
      end
    end
  end
end
