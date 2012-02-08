class Drive < ActiveRecord::Base
  validates :start_city_id, :destination_city_id, :seats, :free_seats, 
            :date, :is_up_to_date, :user, :presence => true
  validate :drive_date_cannot_be_in_the_past
  
  belongs_to :user
  belongs_to :start_city, :class_name => "City", :foreign_key => "start_city_id"
  belongs_to :destination_city, :class_name => "City", :foreign_key => "destination_city_id"
  
  has_many :mid_locations, :dependent => :destroy
  has_many :cities, :through => :mid_locations, :dependent => :destroy
  
  def Drive.search(start, destination)
    Drive.where(:start_city_id => start.id, :destination_city_id => destination.id) + Drive.findByMidLocs(start, destination)
  end
  
  def drive_date_cannot_be_in_the_past
    if !date.blank? && date<Date.today
      errors.add :date, "drive date can't be in the past"
    end
  end
    
  def add_mid_location(city)
    count = self.mid_locations.length+1
    self.mid_locations << MidLocation.create({:drive_id => self.id, :city_id => city.id, :order => count})
    self.save
  end
  
  def remove_mid_locations(city)
    mids = self.mid_locations.where({:city_id => city.id})
    mids.each do |mid|
      self.mid_locations.delete(mid)
    end
  end
  
  private
  def Drive.findByMidLocs(start, dest)
    Drive.find_by_sql("SELECT drives.*, sname.name, dname.name FROM drives JOIN mid_locations AS start 
ON drives.id=start.drive_id 
JOIN mid_locations AS dest ON drives.id=dest.drive_id JOIN cities AS sname 
ON sname.id=start.city_id JOIN cities AS dname ON dname.id=dest.city_id
WHERE start.order<dest.order AND (sname.id=" + start.id.to_s + " OR drives.start_city_id=" + start.id.to_s + ") 
AND (dname.id=" + dest.id.to_s + " OR drives.destination_city_id=" + dest.id.to_s + ");")
  end
end
