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
      validate_scope
        .then(:validate_description)
        .then(:update_todo_description)
    end

    private

      def validate_scope
        id.valid? && user_id.valid? ? Success(:valid_scope) : Failure(:invalid_scope)
      end

      def validate_description
        return Success(:valid_description) if description.valid?

        Failure(:invalid_description, result: {error: description.validation_error})
      end

      def update_todo_description
        updated = repository.update_description(description, user_id:, id:)

        updated ? Success(:todo_description_updated) : Failure(:todo_not_found)
      end
  end
end
