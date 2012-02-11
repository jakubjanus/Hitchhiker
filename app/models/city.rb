class City < ActiveRecord::Base
  validates :name, :longitude, :latitude, :presence => true
  
  has_many :drives_as_start, :class_name => "Drive", :foreign_key => "start_city_id"
  has_many :drives_as_destination, :class_name => "Drive", :foreign_key => "destination_city_id"
  has_many :mid_locations
  has_many :drives, :through => :mid_locations
  
  after_initialize :round_coordinates
  
  def City.findByCoordinates(lat,long)
    City.where({:longitude => long, :latitude => lat}).first
  end
  
  def City.findByName(name)
    City.where(:name => name).first
  end
  
  private
  def round_coordinates
    if self.latitude and self.longitude
      self.latitude = self.latitude.to_f.round(3)
      self.longitude = self.longitude.to_f.round(3)
    end
  end
end
