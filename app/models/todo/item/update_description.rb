# frozen_string_literal: true

module Todo::Item
  class UpdateDescription < ::Micro::Case
    attribute :id, default: proc(&::Kind::ID)
    attribute :user_id, default: proc(&::Kind::ID)
    attribute :description, default: proc(&::Todo::Description)
    attribute :repository, {
      default: Repository,
      validates: {kind: {respond_to: :update_description}}
    }

    def call!
      return Failure(:invalid_scope) if id.invalid? || user_id.invalid?

      return Failure(:invalid_description, result: {error: description.validation_error}) if description.invalid?

      updated = repository.update_description(description, user_id:, id:)

      updated ? Success(:todo_description_updated) : Failure(:todo_not_found)
    end
  end
end
