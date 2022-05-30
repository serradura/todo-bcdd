# frozen_string_literal: true

module Todo::Item
  class Delete < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :delete_item}}
    }

    def call!
      return Failure(:invalid_scope) if scope.invalid?

      deleted = repository.delete_item(scope:)

      deleted ? Success(:todo_deleted) : Failure(:todo_not_found)
    end
  end
end
