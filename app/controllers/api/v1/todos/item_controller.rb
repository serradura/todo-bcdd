# frozen_string_literal: true

module API::V1::Todos
  class ItemController < BaseController
    def index
      ::Todo::Filter
        .call(user_id: current_user.id, status: params[:status]&.to_sym)
        .on_success { |result| render_todos(result) }
        .on_failure(:invalid_attributes) { |result| render_activemodel_errors(result[:errors]) }
    end

    def show
      ::Todo::Find
        .call(id: params[:id], user_id: current_user.id)
        .on_success { |result| render_todo(result) }
        .on_failure(:todo_not_found) { render_json(status: :not_found) }
        .on_unknown { raise NotImplementedError }
    end

    def create
      description = params.require(:todo)[:description]

      ::Todo::Create
        .call(description:, user_id: current_user.id)
        .on_success { |result| render_todo(result) }
        .on_failure(:user_not_found) { raise NotImplementedError }
        .on_failure(:invalid_attributes) { |result| render_activemodel_errors(result[:errors]) }
    rescue ActionController::ParameterMissing => exception
      render json: {error: exception.message}, status: :bad_request
    end

    def update
      description = params.require(:todo)[:description]

      ::Todo::UpdateDescription
        .call(description:, id: params[:id], user_id: current_user.id)
        .on_success { render_json }
        .on_failure(:todo_not_found) { render_json(status: 404) }
        .on_failure(:invalid_attributes) { |result| render_activemodel_errors(result[:errors]) }
        .on_unknown { raise NotImplementedError }
    rescue ActionController::ParameterMissing => exception
      render json: {error: exception.message}, status: :bad_request
    end

    def delete
      ::Todo::Delete
        .call(id: params[:id], user_id: current_user.id)
        .on_success { render_json }
        .on_failure(:todo_not_found) { render_json(status: 404) }
        .on_unknown { raise NotImplementedError }
    end

    private

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
  end
end
