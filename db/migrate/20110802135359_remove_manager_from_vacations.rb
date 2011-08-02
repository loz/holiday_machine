class RemoveManagerFromVacations < ActiveRecord::Migration
  def self.up
    remove_column :vacations, :manager_id
  end

  def self.down
    add_column :vacations, :manager_id,:integer
  end
end
