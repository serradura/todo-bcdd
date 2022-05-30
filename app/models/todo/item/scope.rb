# frozen_string_literal: true

module Todo::Item
  class Scope
    include ::Micro::Attributes.with(:initialize)

    attribute :id,       default: proc(&::Kind::ID)
    attribute :owner_id, default: proc(&::Kind::ID)

    def valid? = owner_id.valid? && id.valid?

    def invalid? = !valid?
  end
end
