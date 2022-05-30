# frozen_string_literal: true

module Todo::Item
  class Uncomplete < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :uncomplete_item}}
    }

    def call!
      return Failure(:invalid_scope) if scope.invalid?

      uncompleted = repository.uncomplete_item(scope:)

      uncompleted ? Success(:todo_uncompleted) : Failure(:todo_not_found)
    end
  end
end
