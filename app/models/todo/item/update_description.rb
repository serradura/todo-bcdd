# frozen_string_literal: true

class Todo::Item::UpdateDescription < ::Micro::Case
  attribute :id, validates: {numericality: {only_integer: true}}
  attribute :user_id, validates: {numericality: {only_integer: true}}
  attribute :description, validates: {presence: true}

  def call!
    updated = ::Todo.where(user_id:, id:).update_all(description: description)

    return Failure(:todo_not_found) if updated.zero?

    Success(:todo_description_updated)
  end
end
