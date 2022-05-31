# frozen_string_literal: true

module Todo
  module List
    module Repository
      extend self

      def add_item(scope, description:)
        created_at = ::Time.current
        updated_at = created_at
        completed_at = nil

        data = {created_at:, updated_at:, completed_at:, description: description.value}

        result = Item::Record.insert(data.merge(user_id: scope.owner_id.value))

        Item.new(id: result.first['id'], **data)
      rescue ActiveRecord::InvalidForeignKey
        nil
      end

      AsItem = ->((id, description, completed_at, created_at, updated_at)) do
        Item.new(id:, description:, completed_at:, created_at:, updated_at:)
      end

      def filter_items(scope, status:)
        filter_by_status(Item::Record, status)
          .where(user_id: scope.owner_id.value)
          .pluck(:id, :description, :completed_at, :created_at, :updated_at)
          .map!(&AsItem)
      end

      private

        def filter_by_status(relation, status)
          return relation.where.not(completed_at: nil) if status.completed?

          relation.where(completed_at: nil)
        end
    end
  end
end
