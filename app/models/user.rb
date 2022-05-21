# frozen_string_literal: true

class User < ApplicationRecord
  has_many :todos, dependent: nil, class_name: '::Todo::Item::Record'

  validates :email, {
    :presence   => true,
    :format     => ::URI::MailTo::EMAIL_REGEXP,
    :uniqueness => true
  }

  validates :encrypted_password, {
    :presence => true
  }

  validates :api_token, {
    :presence => true,
    :length   => {is: 36}
  }
end
