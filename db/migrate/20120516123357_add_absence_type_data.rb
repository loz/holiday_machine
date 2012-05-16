class AddAbsenceTypeData < ActiveRecord::Migration
  def self.up
    connection = ActiveRecord::Base.connection();
    connection.execute("INSERT INTO absence_types (name) VALUES('Holiday'),('Illness'),('Maternity/Paternity'), ('Family'), ('Other');")
  end

  def self.down
  end
end
