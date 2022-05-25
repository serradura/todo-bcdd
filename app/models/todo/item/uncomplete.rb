# frozen_string_literal: true

module Todo::Item
  class Uncomplete < ::Micro::Case
    attribute :id, validates: {numericality: {only_integer: true}}
    attribute :user_id, validates: {numericality: {only_integer: true}}
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :uncomplete_item}}
    }

    def call!
      uncompleted = repository.uncomplete_item(user_id:, id:)

      return Failure(:todo_not_found) unless uncompleted

      Success(:todo_uncompleted)
    end
  end
end
