# frozen_string_literal: true

module Todo::Item
  class Find < ::Micro::Case
    attribute :id, default: proc(&::Kind::ID)
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :find_item}}
    }

    def call!
      return Failure(:invalid_scope) if id.invalid? || user_id.invalid?

      todo = repository.find_item(user_id:, id:)

      return Failure(:todo_not_found) unless todo

      Success :todo_found, result: {todo:}
    end
  end
end
