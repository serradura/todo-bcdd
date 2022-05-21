# frozen_string_literal: true

module Todos::List
  class UncompletedController < ::Todos::BaseController
    def index
      ::Todo::List::FilterItems
        .call(user_id: current_user.id, status: :uncompleted)
        .on_failure { raise NotImplementedError }
        .on_success do |result|
          render('todos/list/uncompleted', locals: {todos: result[:todos]})
        end
    end
  end
end
