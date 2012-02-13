class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.references :user, :null => false
      t.references :drive, :null => false
      t.boolean :is_accepted, :default => false
      t.timestamps
    end
  end
end
