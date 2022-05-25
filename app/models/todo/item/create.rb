# frozen_string_literal: true

module Todo::Item
  class Create < ::Micro::Case
    attribute :user_id, validates: {numericality: {only_integer: true}}
    attribute :description, validates: {presence: true}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :add_item}}
    }

    def call!
      todo = repository.add_item(user_id:, description:)

      return Failure(:user_not_found) if todo.errors.of_kind?(:user, :blank)

      return Success(:todo_created, result: {todo:}) if todo.persisted?

      raise NotImplementedError
    end
  end
end
