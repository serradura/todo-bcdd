# frozen_string_literal: true

module Todo::Item
  class Delete < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}

    def call!
      deleted = Record.where(user_id:, id:).delete_all

      return Failure(:todo_not_found) if deleted.zero?

      Success(:todo_deleted)
    end
  end
end
