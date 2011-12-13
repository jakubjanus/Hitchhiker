class CreateMidLocations < ActiveRecord::Migration
  def change
    create_table :mid_locations do |t|
      t.references :drive, :null => false
      t.references :city, :null => false
      t.integer :order, :null => false, :default => 0
      t.timestamps
    end
  end
end
