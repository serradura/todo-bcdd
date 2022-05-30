# frozen_string_literal: true

module Todo::Item
  class Complete < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :complete_item}}
    }

    def call!
      return Failure(:invalid_scope) if scope.invalid?

      completed = repository.complete_item(scope:)

      return Failure(:todo_not_found) unless completed

      Success(:todo_completed)
    end
  end
end
