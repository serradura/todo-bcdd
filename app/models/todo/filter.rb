# frozen_string_literal: true

class Todo::Filter < ::Micro::Case
  attribute :status, validates: {inclusion: {in: [:completed, :uncompleted]}}
  attribute :user_id, validates: {numericality: {only_integer: true}}

  def call!
    relation = status == :completed ? ::Todo.completed : ::Todo.uncompleted

    Success :todos_filtered, result: {todos: relation.where(user_id:)}
  end
end
