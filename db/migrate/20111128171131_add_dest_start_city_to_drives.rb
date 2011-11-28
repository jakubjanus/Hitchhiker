class AddDestStartCityToDrives < ActiveRecord::Migration

  def up
    change_table :drives do |t|
      t.integer :start_city_id, :null => false
      t.integer :destination_city_id, :null => false
    end
    add_cities_references
    
    change_table :drives do |t|
      t.remove :start_address
      t.remove :destination_address
    end
  end
  
  def down
    change_table :drives do |t|
      t.string :start_address
      t.string :destination_address
    end
    get_names_from_cities
    
    change_table :drives do |t|
      t.remove :start_city_id
      t.remove :destination_city_id
    end
  end
  
  def add_cities_references
    Drive.all do |drive|
      drive.start_city_id = City.findByName(drive.start_address).id
      drive.destination_city_id = City.findByName(drive.destination_address).id
      drive.save
    end
  end
  
  def get_names_from_cities
    Drive.all do |drive|
      drive.start_address = City.find(drive.start_city_id).name
      drive.destination_address = City.find(drive.destination_city_id).name
      drive.save
    end
  end
end
