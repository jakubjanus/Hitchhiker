class City < ActiveRecord::Base
  validates :name, :longitude, :latitude, :presence => true
  
  has_many :drives_as_start, :class_name => "Drive", :foreign_key => "start_city_id"
  has_many :drives_as_destination, :class_name => "Drive", :foreign_key => "destination_city_id"
  
  def City.findByCoordinates(lat,long)
    City.where({:longitude => long, :latitude => lat}).first
  end
  def City.findByName(name)
    City.where(:name => name).first
  end
end
