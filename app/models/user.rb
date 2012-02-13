 # -*- coding: utf-8 -*-
class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:login]
  validates :name, :presence => true

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :login
  attr_accessor :login
  
  has_many :drives, :class_name => 'Drive'
  has_many :messages_as_sender, :class_name => "Message", :foreign_key => "sender_id"
  has_many :messages_as_recipient, :class_name => "Message", :foreign_key => "recipient_id"
  has_many :messages, :class_name => 'Message', :foreign_key => 'owner_id'
  has_many :reservations
  belongs_to :hometown, :class_name => "City", :foreign_key => "hometown_id"
  
  
  def User.get_visibilities
    ['everyone', 'registered', 'nobody']
  end
  
  def self.find_for_database_authentication(warden_conditions)
   conditions = warden_conditions.dup
   login = conditions.delete(:login)
   where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
  end
  
  def get_accepted_reservations
    res = []
    self.reservations.each do |reservation|
      res << reservation if reservation.is_accepted
    end
    res
  end
  
  def get_unaccepted_reservations
    res = []
    self.reservations.each do |reservation|
      res << reservation unless reservation.is_accepted
    end
    res
  end
  
  def get_accepted_reservations_from_my_drives
    res = []
    self.drives.each do |drive|
      drive.get_accepted_reservations.each do |reservation|
        res << reservation if reservation.is_accepted
      end
    end
    res
  end
  
  def get_unaccepted_reservations_from_my_drives
    res = []
    self.drives.each do |drive|
      drive.get_accepted_reservations.each do |reservation|
        res << reservation unless reservation.is_accepted
      end
    end
    res
  end
  
  def make_reservation(drive)
    if drive.free_seats > 0
      Reservation.create({:user => self, :drive => drive})
      send_message(drive.user, 'Rezerwacja', 'Witam. Zgłaszam rezerwację dotyczącą' + 
        ' przejazdu  numer ' + drive.id.to_s + '. Z ' + drive.start_city.name +
        ' do ' + drive.destination_city.name)
    end
  end
  
  def accept_reservation(reservation)
    if reservation.drive.user.id == self.id
      if reservation.drive.accept_reservation(reservation)
        send_message(reservation.user, 'Zaakceptowana rezerwacja', 'Twoja rezerwacja została zaakceptowana.')
      end    
    end
  end
  
  def check_if_already_reserved(drive)
    cond = false
    self.reservations.each do |reservation|
      cond = true if reservation.drive.id == drive.id
    end
    cond
  end
  
  def send_message(recipient, title, contents)
    Message.create({:sender_id => self.id, :recipient_id => recipient.id, 
      :contents => contents, :title => title, :owner_id => self.id})
    Message.create({:sender_id => self.id, :recipient_id => recipient.id, 
      :contents => contents, :title => title, :owner_id => recipient.id})
  end
  
  def get_unread_messages
    res = []
    self.messages.each do |message|
      res << message unless message.is_read or message.recipient.id != self.id
    end
    res
  end
  
  def get_read_messages
    res = []
    self.messages.each do |message|
      res << message if message.is_read and message.recipient.id == self.id
    end
    res
  end
  
  def get_up_to_date_drives
    res = []
    self.drives.each do |drive|
      res << drive if drive.is_up_to_date
    end
    res
  end
  
  def get_archival_drives
    res = []
    self.drives.each do |drive|
      res << drive unless drive.is_up_to_date
    end
    res
  end
  
  def set_user_data(data)
    self.first_name = data['first_name'] if data['first_name'] and name_check(data['first_name'])
    self.last_name = data['last_name'] if data['last_name'] and name_check(data['last_name'])
    self.set_phone_number(data['phone_number']) if data["phone_number"]
    self.email = data['email'] if data['email'] and email_check(data['email'])
    self.alt_email = data['alt_email'] if data['alt_email'] and email_check(data['alt_email'])
    self.birthdate = build_date(data['birthdate']) if data['birthdate']
    self.hometown = City.findOrCreate(data['hometown']) if data['hometown']
    
    # and visibilities
    
    self.save
  end
  
  def set_hometown(city)
    self.hometown_id = city.id
  end
  
  def set_phone_number(number)
    if number =~ %r{([[+]*\d\d]*)[-]*(\d\d\d)[-]*(\d\d\d)[-]*(\d\d\d)}
      self.phone_number = number
    end
  end
  
  def set_hometown_visibility(visibility)
    if visibility_check(visibility)
      self.show_hometown = visibility
      self.save
    end
  end
  
  def set_email_visibility(visibility)
    if visibility_check(visibility)
      self.show_email = visibility
      self.save
    end
  end
  
  def set_alt_email_visibility(visibility)
    if visibility_check(visibility)
      self.show_alt_email = visibility
      self.save
    end
  end
  
  def set_phone_number_visibility(visibility)
    if visibility_check(visibility)
      self.show_phone_number = visibility
      self.save
    end
  end
  
  private
  def email_check(email)
    email =~ %r{^[0-9a-z][0-9a-z.+]+[0-9a-z]@[0-9a-z][0-9a-z.-]+[0-9a-z]$}xi
  end
  
  def name_check(name)
    name =~ %r{^[(A-Z)|(a-z)]+$}
  end
  
  def visibility_check(visibility)
    ['everyone', 'registered', 'nobody'].include?(visibility)
  end
  
  def build_date(value)
    date = nil
    if value =~ %r{(\d\d)-(\d\d)-(\d\d\d\d)}
      date = Date.new($3.to_i,$2.to_i,$1.to_i)
    end
    date
  end
end
