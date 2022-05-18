# frozen_string_literal: true

module Todos
  class BaseController < ApplicationController
    layout 'todos/application'

    before_action :authenticate_user!
  end
end
