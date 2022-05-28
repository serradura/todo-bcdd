# frozen_string_literal: true

module Todos
  class ItemController < BaseController
    def new
      render_new
    end

    def create
      description = params.require(:todo)[:description]

      ::Todo::Item::Create
        .call(description:, user_id: current_user.id)
        .on_success { redirect_after_creating }
        .on_failure(:user_not_found) { raise NotImplementedError }
        .on_failure(:invalid_description) do |result|
          render_new(description:, form_errors: {description: result[:error]})
        end
    end

    def edit
      ::Todo::Item::Find
        .call(id: params[:id], user_id: current_user.id)
        .on_success { |result| render_edit_with_todo(result[:todo]) }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_unknown { raise NotImplementedError }
    end

    def update
      description = params.require(:todo)[:description]

      ::Todo::Item::UpdateDescription
        .call(description:, id: params[:id], user_id: current_user.id)
        .on_success { redirect_after_updating }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_failure(:invalid_description) { |result| handle_updating_errors(result[:error], description:) }
        .on_unknown { raise NotImplementedError }
    end

    def delete
      ::Todo::Item::Delete
        .call(id: params[:id], user_id: current_user.id)
        .on_success { redirect_after_deleting }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_unknown { raise NotImplementedError }
    end

    private

      def render_new(form_errors: {}, description: nil)
        render('todos/item/new', locals: {form_errors:, description:})
      end

      def redirect_after_creating
        redirect_to(todos_uncompleted_path, notice: 'To-do successfully created.')
      end

      def render_edit(todo_id:, todo_description:, form_errors: {})
        previous = params.fetch(:previous)

        render('todos/item/edit', locals: {form_errors:, todo_id:, todo_description:, previous:})
      end

      def render_edit_with_todo(todo)
        render_edit(todo_id: todo.id, todo_description: todo.description)
      end

      def redirect_after_updating
        next_path = params[:previous] == 'completed' ? todos_completed_path : todos_uncompleted_path

        redirect_to(next_path, notice: 'To-do successfully updated.')
      end

      def handle_todo_not_found
        redirect_back_or_to(todos_uncompleted_path, notice: 'To-do not found or unavailable.')
      end

      def handle_updating_errors(error, description:)
        render_edit(todo_id: params[:id], todo_description: description, form_errors: {description: error})
      end

      def redirect_after_deleting
        next_path = params[:previous] == 'completed' ? todos_completed_path : todos_uncompleted_path

        redirect_to(next_path, notice: 'To-do successfully deleted.')
      end
  end
end
