# frozen_string_literal: true

class CreateTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todos do |t|
      t.text :description, null: false
      t.datetime :completed_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :todos, [:user_id, :id]
  end
end
