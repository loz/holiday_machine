class RenameVacations < ActiveRecord::Migration
  def self.up
    rename_table :vacations, :absences
  end

  def self.down
    rename_table :absences, :vacations
  end
end
