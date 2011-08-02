class RemoveDaysLeaveFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :days_leave
  end

  def self.down
    add_column :users, :days_leave, :integer
  end
end
