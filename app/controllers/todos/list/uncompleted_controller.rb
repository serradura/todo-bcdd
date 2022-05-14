# frozen_string_literal: true

module Todos::List
  class UncompletedController < ::Todos::BaseController
    def index
      render('todos/list/uncompleted')
    end
  end
end
