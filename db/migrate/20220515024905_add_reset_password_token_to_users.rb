# frozen_string_literal: true

class AddResetPasswordTokenToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :reset_password_token, :uuid

    add_index :users, :reset_password_token, unique: true
  end

  def down
    remove_column :users, :reset_password_token
  end
end
