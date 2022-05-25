# frozen_string_literal: true

module Todo
  module List
    class FilterItems < ::Micro::Case
      attribute :status, validates: {inclusion: {in: Status::ALL}}
      attribute :user_id, validates: {numericality: {only_integer: true}}
      attribute :repository, {
        default: Repository,
        validates: {kind: {respond_to: :filter_items}}
      }

      def call!
        todos = repository.filter_items(user_id:, status:)

        Success :todos_filtered, result: {todos:}
      end
    end
  end
end
