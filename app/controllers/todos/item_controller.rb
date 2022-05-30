# frozen_string_literal: true

module Todos
  class ItemController < BaseController
    def new
      render_new
    end

    def create
      scope = Todo::List::Scope.new(owner_id: current_user.id)

      description = params.require(:todo)[:description]

      ::Todo::List::AddItem
        .call(scope:, description:)
        .on_success { redirect_after_creating }
        .on_failure(:user_not_found) { raise NotImplementedError }
        .on_failure(:invalid_description) do |result|
          render_new(description:, form_errors: {description: result[:error]})
        end
    end

    def edit
      scope = build_scope(id: params[:id])

      ::Todo::Item::Find
        .call(scope:)
        .on_success { |result| render_edit_with_todo(result[:todo]) }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_unknown { raise NotImplementedError }
    end

    def update
      scope = build_scope(id: params[:id])

      description = params.require(:todo)[:description]

      ::Todo::Item::UpdateDescription
        .call(scope:, description:)
        .on_success { redirect_after_updating }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_failure(:invalid_description) { |result| handle_updating_errors(result[:error], description:) }
        .on_unknown { raise NotImplementedError }
    end

    def delete
      scope = build_scope(id: params[:id])

      ::Todo::Item::Delete
        .call(scope:)
        .on_success { redirect_after_deleting }
        .on_failure(:todo_not_found) { handle_todo_not_found }
        .on_unknown { raise NotImplementedError }
    end

    private

      def build_scope(id:)
        ::Todo::Item::Scope.new(owner_id: current_user.id, id: id)
      end

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
