# frozen_string_literal: true

module Todo::Item
  class Uncomplete < ::Micro::Case
    attribute :id, default: proc(&::Kind::ID)
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :uncomplete_item}}
    }

    def call!
      return Failure(:invalid_scope) if id.invalid? || user_id.invalid?

      uncompleted = repository.uncomplete_item(user_id:, id:)

      uncompleted ? Success(:todo_uncompleted) : Failure(:todo_not_found)
    end
  end
end
