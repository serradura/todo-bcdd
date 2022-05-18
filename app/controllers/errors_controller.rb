# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'errors'

  def not_found
    if request.env['REQUEST_PATH'].start_with?('/api')
      render json: {error: 'not_found'}, status: :not_found
    else
      render status: :not_found
    end
  end

  def internal_server_error
    if request.env['REQUEST_PATH'].start_with?('/api')
      render json: {error: 'internal_server_error'}, status: :internal_server_error
    else
      render status: :internal_server_error
    end
  end
end
