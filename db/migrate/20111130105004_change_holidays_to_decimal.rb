class ChangeHolidaysToDecimal < ActiveRecord::Migration
  def self.up
    change_column :vacations, :working_days_used, :decimal, :precision =>4, :scale=>1
    change_column :user_days, :no_days, :decimal, :precision =>4, :scale=>1
    change_column :user_days_for_years, :days_remaining, :decimal, :precision =>4, :scale=>1
    change_column :admins, :days_leave, :decimal, :precision =>4, :scale=>1
  end

  def self.down
    change_column :vacations, :working_days_used, :integer
    change_column :user_days, :no_days, :integer
    change_column :user_days_for_years, :days_remaining, :integer
    change_column :admins, :days_leave, :integer
  end
end
