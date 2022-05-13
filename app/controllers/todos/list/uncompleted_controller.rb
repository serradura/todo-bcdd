# frozen_string_literal: true

module Todos::List
  class UncompletedController < ApplicationController
    layout 'todos/application'

    def index
      render('todos/list/uncompleted')
    end
  end
end
