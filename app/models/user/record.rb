# frozen_string_literal: true

module User
  class Record < ApplicationRecord
    self.table_name = 'users'

    has_many :todos, dependent: nil, class_name: '::Todo::Item::Record', foreign_key: 'user_id'

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
end
