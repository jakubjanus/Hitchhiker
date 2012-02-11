require 'net/http'

class DeleteIncorrectCities < ActiveRecord::Migration
  def up
    add_coordinates
    round_coordinates
  end

  def down
  end
  
  def add_coordinates
    City.all.each do |city|
      unless city.latitude.to_f > 0 and city.longitude.to_f > 0
        url = 'http://maps.googleapis.com/maps/api/geocode/json?' 
        url += URI.encode_www_form("address" => city.name, "sensor" => "false").to_s
        location = ActiveSupport::JSON.decode(Net::HTTP.get(URI(url)))["results"].first["geometry"]["location"]
        
        city.latitude = location["lat"].to_f.round(3)
        city.longitude = location["lng"].to_f.round(3)
        city.save
      end
    end
  end
  
  def round_coordinates
    City.all.each do |city|
      city.latitude = city.latitude.to_f.round(3) unless proper_precision(city.latitude.to_f)
      city.longitude = city.longitude.to_f.round(3) unless proper_precision(city.longitude.to_f)
      city.save
    end
  end
  
  def proper_precision(x)
    x.round(3)==x
  end
end
