class AddAbsenceType < ActiveRecord::Migration
  def self.up
    create_table "absence_types", :force => true do |t|
        t.column "name", :string
    end
    
    add_column :absences, :absence_type_id, :integer
  end

  def self.down
    drop_table :absence_types
  end
end
