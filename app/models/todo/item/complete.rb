# frozen_string_literal: true

module Todo::Item
  class Complete < ::Micro::Case
    attribute :id, default: proc(&::Kind::ID)
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :complete_item}}
    }

    def call!
      return Failure(:invalid_scope) if id.invalid? || user_id.invalid?

      completed = repository.complete_item(user_id:, id:)

      return Failure(:todo_not_found) unless completed

      Success(:todo_completed)
    end
  end
end
