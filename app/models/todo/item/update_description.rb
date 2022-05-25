# frozen_string_literal: true

module Todo::Item
  class UpdateDescription < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}
    attribute :description, validates: {presence: true}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :update_description}}
    }

    def call!
      updated = repository.update_description(description, user_id:, id:)

      return Failure(:todo_not_found) unless updated

      Success(:todo_description_updated)
    end
  end
end
