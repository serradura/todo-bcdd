# frozen_string_literal: true

Micro::Case.config do |config|
  # Use ActiveModel to auto-validate your use cases' attributes.
  config.enable_activemodel_validation = true

  # Use to enable/disable the `Micro::Case::Results#transitions`.
  config.enable_transitions = !::Rails.env.production?
end

class Micro::Case::Result
  def then_expose(*keys)
    return self if failure?

    raise ArgumentError, 'wrong number of arguments (expected at least 1)' if keys.empty?

    type, keys_to_expose =
      keys.size == 1 && keys[0].is_a?(::Hash) ? keys[0].to_a[0] : [:data_exposed, keys]

    available_data = @__accessible_attributes.merge(@__accumulated_data)

    data_to_expose = keys_to_expose.zip(available_data.fetch_values(*keys_to_expose)).to_h

    __set__(true, data_to_expose, type, use_case)
  end

  alias then_return then_expose
end
