# frozen_string_literal: true

module Todo::Item
  module Repository
    extend self

    def add_item(user_id:, description:)
      Record.create(user_id:, description:)
    end

    def find_item(user_id:, id:)
      Record.find_by(user_id:, id:)
    end

    def update_description(description, user_id:, id:)
      update(user_id:, id:, description:)
    end

    def complete_item(user_id:, id:)
      completed_at = ::Time.current

      update(user_id:, id:, completed_at:)
    end

    def uncomplete_item(user_id:, id:)
      update(user_id:, id:, completed_at: nil)
    end

    def delete_item(user_id:, id:)
      deleted = Record.where(user_id:, id:).delete_all

      deleted == 1
    end

    private

      def update(user_id:, id:, **attributes)
        updated = Record.where(user_id:, id:).update_all(attributes)

        updated == 1
      end
  end
end
