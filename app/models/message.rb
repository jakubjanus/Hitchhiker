class Message < ActiveRecord::Base
  validate :sender_and_recipient_cant_be_same
  
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :recipient, :class_name => 'User', :foreign_key => 'recipient_id'
  
  def read_message
    self.is_read = true
    self.save
    self.contents
  end
  
  private
  def sender_and_recipient_cant_be_same
    if sender_id == recipient_id
      errors.add :sender, "Sender and recipient should not be the same person"
    end
  end
end
