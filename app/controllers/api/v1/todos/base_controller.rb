# frozen_string_literal: true

module API::V1::Todos
  class BaseController < ::API::V1::BaseController
    before_action :authenticate_user!
  end
end
