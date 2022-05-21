# frozen_string_literal: true

module Todo
  module Item
    class Record < ApplicationRecord
      self.table_name = 'todos'

      belongs_to :user, class_name: '::User::Record'

      scope :completed, -> { where.not(completed_at: nil) }
      scope :uncompleted, -> { where(completed_at: nil) }

      validates :description, presence: true

      def status = completed? ? Status::COMPLETED : Status::UNCOMPLETED

      def completed? = completed_at.present?

      def uncompleted? = !completed?
    end
  end
end
