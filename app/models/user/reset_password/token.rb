# frozen_string_literal: true

class User::ResetPassword::Token
  FORMAT = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/

  def self.generate
    new(::SecureRandom.uuid)
  end

  def self.valid?(object)
    value = object.is_a?(self) ? object.value : object.to_str

    value.match?(FORMAT)
  end

  attr_reader :value

  def initialize(object)
    @value = object.is_a?(self.class) ? object.value : String(object).strip
  end

  def valid?
    self.class.valid?(self)
  end
end
