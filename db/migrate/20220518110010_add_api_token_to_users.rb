# frozen_string_literal: true

class AddAPITokenToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :api_token, :string, limit: 36, null: false

    add_index :users, :api_token, unique: true
  end
end
