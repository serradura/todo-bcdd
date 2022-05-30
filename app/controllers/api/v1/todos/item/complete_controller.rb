# frozen_string_literal: true

module API::V1::Todos
  class Item::CompleteController < BaseController
    def update
      scope = ::Todo::Item::Scope.new(owner_id: current_user.id, id: params[:id])

      ::Todo::Item::Complete
        .call(scope:)
        .on_success { render(json: {}, status: :ok) }
        .on_failure(:todo_not_found) { render(json: {}, status: :not_found) }
        .on_unknown { raise NotImplementedError }
    end
  end
end
