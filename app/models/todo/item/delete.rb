# frozen_string_literal: true

module Todo::Item
  class Delete < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :delete_item}}
    }

    def call!
      deleted = repository.delete_item(user_id:, id:)

      return Failure(:todo_not_found) unless deleted

      Success(:todo_deleted)
    end
  end
end
