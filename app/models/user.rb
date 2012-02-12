class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]
  validates :name, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :login
  attr_accessor :login
  
  has_many :drives
  
  belongs_to :hometown, :class_name => "City", :foreign_key => "hometown_id"
  
  
  def self.find_for_database_authentication(warden_conditions)
   conditions = warden_conditions.dup
   login = conditions.delete(:login)
   where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end
  
  def set_user_data(data)
    self.first_name = data['first_name'] if data['first_name'] and name_check(data['first_name'])
    self.last_name = data['last_name'] if data['last_name'] and name_check(data['last_name'])
    self.set_phone_number(data['phone_number']) if data["phone_number"]
    self.email = data['email'] if data['email'] and email_check(data['email'])
    self.alt_email = data['alt_email'] if data['alt_email'] and email_check(data['alt_email'])
    self.save
    # birthdate
    # hometown
    # and visibilities
  end
  
  def set_hometown(city)
    self.hometown_id = city.id
  end
  
  def set_phone_number(number)
    if number =~ %r{([[+]*\d\d]*)[-]*(\d\d\d)[-]*(\d\d\d)[-]*(\d\d\d)}
      self.phone_number = number
    end
  end
  
  def set_email_visibility(visibility)
    self.show_email = visibility if visibility_check(visibility)
  end
  
  def set_alt_email_visibility(visibility)
    self.show_alt_email if visibility_check(visibility)
  end
  
  def set_hometown_visibility(visibility)
    self.show_hometown = visibility if visibility_check(visibility)
  end
  
  private
  def visibility_check(visibility)
    visibility == 'everyone' or visibility == 'signed_up'
  end
  
  def email_check(email)
    email =~ %r{^[0-9a-z][0-9a-z.+]+[0-9a-z]@[0-9a-z][0-9a-z.-]+[0-9a-z]$}xi
  end
  
  def name_check(name)
    name =~ %r{^[(A-Z)|(a-z)]+$}
  end
end
