class Drive < ActiveRecord::Base
  validates :start_city_id, :destination_city_id, :seats, :free_seats, 
            :date, :is_up_to_date, :user, :presence => true
  validate :drive_date_cannot_be_in_the_past
  
  belongs_to :user
  belongs_to :start_city, :class_name => "City", :foreign_key => "start_city_id"
  belongs_to :destination_city, :class_name => "City", :foreign_key => "destination_city_id"
  
  def drive_date_cannot_be_in_the_past
    if !date.blank? && date<Date.today
      errors.add :date, "drive date can't be in the past"
    end
  end
end
