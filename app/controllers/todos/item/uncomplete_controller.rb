# frozen_string_literal: true

module Todos
  class Item::UncompleteController < BaseController
    def update
      ::Todo::Item::Uncomplete
        .call(id: params[:id], user_id: current_user.id)
        .on_success { redirect_after_updating }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_unknown { raise NotImplementedError }
    end

    private

      def redirect_after_updating
        redirect_to(todos_uncompleted_path, notice: 'The to-do has become uncompleted.')
      end

      def handle_todo_not_found
        redirect_back_or_to(todos_completed_path, notice: 'To-do not found or unavailable.')
      end
  end
end
