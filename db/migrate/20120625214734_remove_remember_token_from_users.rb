class RemoveRememberTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :remember_token
    remove_column :users, :remember_created_at
  end

  def down
  end
end
