class AddHalfDaysToVacationTable < ActiveRecord::Migration
  def self.up
    change_column :vacations, :date_from, :datetime
    change_column :vacations, :date_to, :datetime
  end

  def self.down
    change_column :vacations, :date_from, :date
    change_column :vacations, :date_to, :date
  end
end
