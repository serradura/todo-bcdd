# frozen_string_literal: true

module Users
  class BaseController < ApplicationController
    layout 'users/guest'
  end
end
