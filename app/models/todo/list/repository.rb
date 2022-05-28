# frozen_string_literal: true

module Todo
  module List
    module Repository
      extend self

      def filter_items(user_id:, status:)
        relation = filter_by_status(Item::Record, status)

        relation.where(user_id: user_id.value)
      end

      private

        def filter_by_status(relation, status)
          return relation.where.not(completed_at: nil) if status.completed?

          relation.where(completed_at: nil)
        end
    end
  end
end
