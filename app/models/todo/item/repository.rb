# frozen_string_literal: true

module Todo::Item
  module Repository
    extend self

    Conditions = ->(scope) do
      {user_id: scope.owner_id.value, id: scope.id.value}
    end

    def find_item(scope:)
      Record.find_by(Conditions[scope])
    end

    def update_description(description, scope:)
      update(scope, description: description.value)
    end

    def complete_item(scope:)
      update(scope, completed_at: ::Time.current)
    end

    def uncomplete_item(scope:)
      update(scope, completed_at: nil)
    end

    def delete_item(scope:)
      deleted = Record.where(Conditions[scope]).delete_all

      deleted == 1
    end

    private

      def update(scope, attributes)
        updated = Record.where(Conditions[scope]).update_all(attributes)

        updated == 1
      end
  end
end
