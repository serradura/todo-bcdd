# frozen_string_literal: true

module Todo::Item
  class Complete < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :complete_item}}
    }

    def call!
      completed = repository.complete_item(user_id:, id:)

      return Failure(:todo_not_found) unless completed

      Success(:todo_completed)
    end
  end
end
