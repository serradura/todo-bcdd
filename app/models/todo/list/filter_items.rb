# frozen_string_literal: true

module Todo::List
  class FilterItems < ::Micro::Case
    attribute :scope, validates: {kind: Scope}
    attribute :status, default: proc(&::Todo::Status)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :filter_items}}
    }

    def call!
      return Failure(:invalid_scope) if scope.invalid?

      return invalid_status if status.invalid?

      todos = repository.filter_items(scope, status:)

      Success :todos_filtered, result: {todos:}
    end

    private

      def invalid_status
        Failure(:invalid_status, result: {error: status.validation_error})
      end
  end
end
