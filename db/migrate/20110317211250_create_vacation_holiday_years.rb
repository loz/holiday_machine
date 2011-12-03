class CreateVacationHolidayYears < ActiveRecord::Migration
  def self.up
    add_column :holiday_years, :description, :string, :length=>50
    add_column :vacations, :holiday_year_id, :integer
  end

  def self.down
    remove_column :holiday_years, :description
    remove_column :vacations, :holiday_year_id
  end
end
