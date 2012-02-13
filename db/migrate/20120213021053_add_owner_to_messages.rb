class AddOwnerToMessages < ActiveRecord::Migration
  def up
    change_table :messages do |t|
      t.integer :owner_id
    end
    duplicate_messages
  end
  
  def down
    
  end
  
  def duplicate_messages
    Message.all.each do |message|
      message.owner_id = message.sender_id
      message.save
      Message.create({:title => message.title, :contents => message.contents, :is_read => false,
        :sender_id => message.sender_id, :recipient_id => message.recipient_id, :owner_id => message.recipient_id})
    end
  end
  
end
