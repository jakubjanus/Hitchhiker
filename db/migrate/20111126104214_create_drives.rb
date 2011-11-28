class CreateDrives < ActiveRecord::Migration
  def change
    create_table :drives do |t|
      t.string :start_address, :null => false
      t.string :destination_address, :null => false
      t.integer :seats, :null => false, :default => 1
      t.integer :free_seats
      t.date :date, :null => false
      t.boolean :is_up_to_date, :null => false, :default => true
      t.references :user, :null => false

      t.timestamps
    end
  end
end
