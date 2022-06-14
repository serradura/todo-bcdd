# frozen_string_literal: true

module JsonResponseHelperMethod
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include JsonResponseHelperMethod, type: :controller
end
