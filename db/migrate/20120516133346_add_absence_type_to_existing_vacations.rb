class AddAbsenceTypeToExistingVacations < ActiveRecord::Migration
  def self.up
    #Sets all existing absences to holiday (which is what they are!!)
    connection = ActiveRecord::Base.connection();
    connection.execute("UPDATE absences SET absence_type_id = 1;")
  end

  def self.down
  end
end
