# frozen_string_literal: true

module Todo::Item
  class Find < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}

    def call!
      todo = Record.find_by(user_id:, id:)

      return Failure(:todo_not_found) unless todo

      Success :todo_found, result: {todo:}
    end
  end
end
