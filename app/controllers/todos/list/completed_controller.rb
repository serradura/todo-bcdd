# frozen_string_literal: true

module Todos::List
  class CompletedController < ApplicationController
    layout 'todos/application'

    def index
      render('todos/list/completed')
    end
  end
end
