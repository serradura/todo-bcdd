# frozen_string_literal: true

class Todo < ApplicationRecord
  belongs_to :user

  scope :completed, -> { where.not(completed_at: nil) }
  scope :uncompleted, -> { where(completed_at: nil) }

  validates :description, presence: true

  def status = completed? ? :completed : :uncompleted

  def completed? = completed_at.present?

  def uncompleted? = !completed?
end
