class Reservation < ActiveRecord::Base
  validate :cant_reserve_two_times
  
  belongs_to :user
  belongs_to :drive
  
  def accept
    self.is_accepted = true
  end
  
  private
  def cant_reserve_two_times
    if User.find(user_id).check_if_already_reserved(Drive.find(drive_id))
      errors.add :user, "You can reserve a drive only once."
    end
  end
end
