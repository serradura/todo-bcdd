# frozen_string_literal: true

module Todo::Item
  class Create < ::Micro::Case
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :description, default: proc(&::Todo::Description)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :add_item}}
    }

    def call!
      return Failure(:invalid_scope) if user_id.invalid?

      return Failure(:invalid_description, result: {error: description.validation_error}) if description.invalid?

      todo = repository.add_item(user_id:, description:)

      return Failure(:user_not_found) if todo.errors.of_kind?(:user, :blank)

      raise NotImplementedError unless todo.persisted?

      Success(:todo_created, result: {todo:})
    end
  end
end
