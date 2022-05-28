# frozen_string_literal: true

module Todo
  module List
    class FilterItems < ::Micro::Case
      attribute :status, default: proc(&::Todo::Status)
      attribute :user_id, default: proc(&::Kind::ID)
      attribute :repository, {
        default: Repository,
        validates: {kind: {respond_to: :filter_items}}
      }

      def call!
        return invalid_status if status.invalid?

        return Failure(:invalid_scope) if user_id.invalid?

        todos = repository.filter_items(user_id:, status:)

        Success :todos_filtered, result: {todos:}
      end

      private

        def invalid_status = Failure(:invalid_status, result: {error: status.validation_error})
    end
  end
end
