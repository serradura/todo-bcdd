# frozen_string_literal: true

module Todo
  module List
    module Repository
      extend self

      def add_item(scope, description:)
        user_id = scope.owner_id.value

        Item::Record.create(user_id:, description: description.value)
      end

      def filter_items(scope, status:)
        relation = filter_by_status(Item::Record, status)

        relation.where(user_id: scope.owner_id.value)
      end

      private

        def filter_by_status(relation, status)
          return relation.where.not(completed_at: nil) if status.completed?

          relation.where(completed_at: nil)
        end
    end
  end
end
