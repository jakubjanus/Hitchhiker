require 'net/http'

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
  
  def City.findOrCreate(name)
    res = City.findByName(name)
    unless res
      res = City.find_city_in_gm(name)
      if City.findByCoordinates(res.latitude.to_f, res.longitude.to_f)
        res = City.findByCoordinates(res.latitude.to_f, res.longitude.to_f)
      else
        res.save
      end
    end
    res
  end
  
  def City.findX(name)
    City.find_city(name)
  end
  
  private
  def round_coordinates
    if self.latitude and self.longitude
      self.latitude = self.latitude.to_f.round(3)
      self.longitude = self.longitude.to_f.round(3)
    end
  rescue ActiveModel::MissingAttributeError
    
  end
  
  def City.find_city_in_gm(name)
    url = 'http://maps.googleapis.com/maps/api/geocode/json?' 
    url += URI.encode_www_form("address" => name, "sensor" => "false").to_s
    location = ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))["results"].first["geometry"]["location"]
    
    City.new({:name => name, :latitude => location["lat"].to_f.round(3), :longitude => location["lng"].to_f.round(3)})
  end
end
