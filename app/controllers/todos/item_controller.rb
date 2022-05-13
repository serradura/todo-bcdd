# frozen_string_literal: true

module Todos
  class ItemController < ApplicationController
    layout 'todos/application'

    def new
      render('todos/item/new')
    end

    def edit
      render('todos/item/edit')
    end
  end
end
