# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'errors'

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end
end
