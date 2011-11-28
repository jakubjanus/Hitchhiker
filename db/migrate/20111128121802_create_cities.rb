class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, :null => false
      t.decimal :latitude, :null => false, :scale => 7
      t.decimal :longitude, :null => false, :scale => 7

      t.timestamps
    end
  end
end
