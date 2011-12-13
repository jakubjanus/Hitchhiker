class MidLocation < ActiveRecord::Base
  belongs_to :drive
  belongs_to :city
  
  after_destroy :update_order
  
  def update_order
    mids = MidLocation.where('drive_id = :dr_id AND "order" > :ord',{:dr_id => self.drive.id, :ord => self.order})
    mids.each do |mid|
      if mid.order > self.order
        mid.order = mid.order-1
        mid.save
      end
    end
  end

end
