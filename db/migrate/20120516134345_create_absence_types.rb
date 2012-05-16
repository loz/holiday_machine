class CreateAbsenceTypes < ActiveRecord::Migration
  def self.up
    create_table :absence_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :absence_types
  end
end
