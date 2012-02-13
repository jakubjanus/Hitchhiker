class AddDefaultAttrVisibilitiesToUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.set_email_visibility('everyone') unless user.show_email
      user.set_alt_email_visibility('everyone') unless user.show_alt_email
      user.set_hometown_visibility('everyone') unless user.show_hometown
      user.set_phone_number_visibility('everyone') unless user.show_phone_number
    end
  end
  
  def down
    
  end
end
