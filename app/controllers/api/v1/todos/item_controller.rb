# frozen_string_literal: true

module API::V1::Todos
  class ItemController < BaseController
    def index
      scope = ::Todo::List::Scope.new(owner_id: current_user.id)

      ::Todo::List::FilterItems
        .call(scope:, status: params[:status])
        .on_success { |result| render_todos(result) }
        .on_failure(:invalid_status) { |result| render_invalid(:status, result) }
        .on_unknown { raise NotImplementedError }
    end

    def show
      scope = build_scope(id: params[:id])

      ::Todo::Item::Find
        .call(scope:)
        .on_success { |result| render_todo(result) }
        .on_failure(:todo_not_found) { render_json(status: :not_found) }
        .on_unknown { raise NotImplementedError }
    end

    def create
      scope = ::Todo::List::Scope.new(owner_id: current_user.id)

      description = params.require(:todo)[:description]

      ::Todo::List::AddItem
        .call(scope:, description:)
        .on_success { |result| render_todo(result) }
        .on_failure(:user_not_found) { raise NotImplementedError }
        .on_failure(:invalid_description) { |result| render_invalid(:description, result) }
        .on_unknown { raise NotImplementedError }
    rescue ActionController::ParameterMissing => exception
      render json: {error: exception.message}, status: :bad_request
    end

    def update
      scope = build_scope(id: params[:id])

      description = params.require(:todo)[:description]

      ::Todo::Item::UpdateDescription
        .call(scope:, description:)
        .on_success { render_json }
        .on_failure(:todo_not_found) { render_json(status: 404) }
        .on_failure(:invalid_description) { |result| render_invalid(:description, result) }
        .on_unknown { raise NotImplementedError }
    rescue ActionController::ParameterMissing => exception
      render json: {error: exception.message}, status: :bad_request
    end

    def delete
      scope = build_scope(id: params[:id])

      ::Todo::Item::Delete
        .call(scope:)
        .on_success { render_json }
        .on_failure(:todo_not_found) { render_json(status: 404) }
        .on_unknown { raise NotImplementedError }
    end

    private

      def build_scope(id:)
        ::Todo::Item::Scope.new(id:, owner_id: current_user.id)
      end

      def render_json(data: {}, status: :ok)
        render(status:, json: data)
      end

      def render_todo(result)
        render_json(data: result[:todo].as_json)
      end

      def render_todos(result)
        render_json(data: {todos: result[:todos].map(&:as_json)})
      end

      def render_activemodel_errors(errors)
        data = errors.messages.transform_values { |messages| messages.join(', ') }

        render_json(data:, status: :unprocessable_entity)
      end

      def render_invalid(attribute, result)
        render_json(status: :unprocessable_entity, data: {attribute => result[:error]})
      end
  end
end
