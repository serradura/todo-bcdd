# frozen_string_literal: true

class User < ApplicationRecord
  has_many :todos

  validates :email, {
    :presence   => true,
    :format     => ::URI::MailTo::EMAIL_REGEXP,
    :uniqueness => true
  }

  validates :encrypted_password, {
    :presence => true
  }
end
