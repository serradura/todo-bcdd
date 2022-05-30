# frozen_string_literal: true

module Todo::List
  class Scope
    include ::Micro::Attributes.with(:initialize)

    attribute :owner_id, default: proc(&::Kind::ID)

    def valid? = owner_id.valid?

    def invalid? = !valid?
  end
end
