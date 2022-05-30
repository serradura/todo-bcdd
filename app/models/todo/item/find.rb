# frozen_string_literal: true

module Todo::Item
  class Find < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :find_item}}
    }

    def call!
      return Failure(:invalid_scope) if scope.invalid?

      todo = repository.find_item(scope:)

      return Failure(:todo_not_found) unless todo

      Success :todo_found, result: {todo:}
    end
  end
end
