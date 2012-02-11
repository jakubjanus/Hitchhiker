class Drive < ActiveRecord::Base
  validates :start_city_id, :destination_city_id, :seats, :free_seats, 
            :date, :user, :presence => true
  validate :drive_date_cannot_be_in_the_past, :cost_cant_be_negative, 
           :distance_cant_be_negative, :free_seats_should_not_be_greater_then_seats
  
  belongs_to :user
  belongs_to :start_city, :class_name => "City", :foreign_key => "start_city_id"
  belongs_to :destination_city, :class_name => "City", :foreign_key => "destination_city_id"
  
  has_many :mid_locations, :dependent => :destroy
  has_many :cities, :through => :mid_locations, :dependent => :destroy
  
  
  def Drive.search(start, destination)
    if start and destination
      (Drive.where(:start_city_id => start.id, :destination_city_id => destination.id) + 
        Drive.findByMidLocs(start, destination)).uniq
    end
  end
  
  def Drive.search_up_to_date(start, destination)
    if start and destination
      Drive.get_up_to_date(Drive.search(start, destination))
    end
  end
  
  def get_info_json
    {:id => self.id, :date => self.date, :free_seats => self.free_seats, :is_up_to_date => self.is_up_to_date, 
      :start_city => self.start_city.name, :destination_city => self.destination_city.name}
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
  
  def is_up_to_date
    self.date > Date.today
  end
  
  private
  def Drive.findByMidLocs(start, dest)
    Drive.find_by_sql("SELECT DISTINCT drives.* FROM drives JOIN mid_locations AS start " + 
      "ON drives.id=start.drive_id JOIN mid_locations AS dest ON drives.id=dest.drive_id JOIN cities AS sname " + 
      "ON sname.id=start.city_id JOIN cities AS dname ON dname.id=dest.city_id " +
      "WHERE (start.order<dest.order AND sname.id=" + start.id.to_s + " AND dname.id=" + dest.id.to_s +
      ") OR ( (sname.id=" + start.id.to_s + " OR drives.start_city_id=" + start.id.to_s + 
      ") AND (dname.id=" + dest.id.to_s + " OR drives.destination_city_id=" + dest.id.to_s + ") );")
  end
  
  def Drive.get_up_to_date(drives)
    res = []
    for drive in drives
      res << drive if drive.is_up_to_date
    end
    res
  end
  
  def drive_date_cannot_be_in_the_past
    if !date.blank? && date<Date.today
      errors.add :date, "Drive date can't be in the past"
    end
  end
  
  def cost_cant_be_negative
    if cost < 0
      errors.add :cost, "Cost value can't be negative"
    end
  end
  
  def distance_cant_be_negative
    if distance < 0
      errors.add :distance, "Distance can't be negative"
    end
  end
  
  def free_seats_should_not_be_greater_then_seats
    if seats < free_seats
      errors.add :free_seats, "Number of free seats should not be greater then numeber of seats"
    end
  end
end
