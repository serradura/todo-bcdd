# frozen_string_literal: true

module Todo::Item
  class Delete < ::Micro::Case
    attribute :id, default: proc(&::Kind::ID)
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :delete_item}}
    }

    def call!
      return Failure(:invalid_scope) if id.invalid? || user_id.invalid?

      deleted = repository.delete_item(user_id:, id:)

      deleted ? Success(:todo_deleted) : Failure(:todo_not_found)
    end
  end
end
