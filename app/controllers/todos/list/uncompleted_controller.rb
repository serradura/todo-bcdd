# frozen_string_literal: true

module Todos::List
  class UncompletedController < ::Todos::BaseController
    def index
      scope = ::Todo::List::Scope.new(owner_id: current_user.id)

      ::Todo::List::FilterItems
        .call(scope:, status: ::Todo::Status::UNCOMPLETED)
        .on_failure { raise NotImplementedError }
        .on_success do |result|
          render('todos/list/uncompleted', locals: {todos: result[:todos]})
        end
    end
  end
end
