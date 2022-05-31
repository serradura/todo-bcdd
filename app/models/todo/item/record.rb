# frozen_string_literal: true

module Todo
  module Item
    class Record < ApplicationRecord
      self.table_name = 'todos'

      belongs_to :user, class_name: '::User::Record'

      validates :description, presence: true
    end
  end
end
