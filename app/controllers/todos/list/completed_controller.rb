# frozen_string_literal: true

module Todos::List
  class CompletedController < ::Todos::BaseController
    def index
      ::Todo::List::FilterItems
        .call(user_id: current_user.id, status: ::Todo::Status::COMPLETED)
        .on_failure { raise NotImplementedError }
        .on_success do |result|
          render('todos/list/completed', locals: {todos: result[:todos]})
        end
    end
  end
end
