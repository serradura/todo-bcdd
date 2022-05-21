# frozen_string_literal: true

module Todo::Item
  class Complete < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}

    def call!
      updated = Record.where(user_id:, id:).update_all(completed_at: ::Time.current)

      return Failure(:todo_not_found) if updated.zero?

      Success(:todo_completed)
    end
  end
end
