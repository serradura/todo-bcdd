# frozen_string_literal: true

module Todos::List
  class CompletedController < ::Todos::BaseController
    def index
      render('todos/list/completed')
    end
  end
end
