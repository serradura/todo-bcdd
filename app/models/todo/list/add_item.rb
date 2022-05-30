# frozen_string_literal: true

module Todo::List
  class AddItem < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :description, default: proc(&::Todo::Description)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :add_item}}
    }

    def call!
      validate_scope
        .then(:validate_description)
        .then(:add_todo_item)
        .then_expose(todo_added: [:todo])
    end

    private

      def validate_scope
        scope.valid? ? Success(:valid_scope) : Failure(:invalid_scope)
      end

      def validate_description
        return Success(:valid_description) if description.valid?

        Failure(:invalid_description, result: {error: description.validation_error})
      end

      def add_todo_item
        todo = repository.add_item(scope, description:)

        return Failure(:user_not_found) if todo.errors.of_kind?(:user, :blank)

        raise NotImplementedError unless todo.persisted?

        Success(result: {todo:})
      end
  end
end
