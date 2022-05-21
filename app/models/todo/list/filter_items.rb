# frozen_string_literal: true

module Todo
  class List::FilterItems < ::Micro::Case
    attribute :status, validates: {inclusion: {in: [:completed, :uncompleted]}}
    attribute :user_id, validates: {numericality: {only_integer: true}}

    def call!
      relation = status == :completed ? Item::Record.completed : Item::Record.uncompleted

      Success :todos_filtered, result: {todos: relation.where(user_id:)}
    end
  end
end
