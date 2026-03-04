class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Rename password_digest to encrypted_password for Devise
    rename_column :users, :password_digest, :encrypted_password

    # Add Devise recoverable columns (for password reset)
    add_column :users, :reset_password_token, :string
    add_index :users, :reset_password_token, unique: true
    add_column :users, :reset_password_sent_at, :datetime

    # Add Devise rememberable columns
    add_column :users, :remember_created_at, :datetime
  end
end
