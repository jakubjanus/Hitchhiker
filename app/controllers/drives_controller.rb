 # -*- coding: utf-8 -*-
class DrivesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:create, :edit, :destroy]
  
  def index
    
  end
  def new
    if current_user
      @logged_in = true
      @user = current_user
      @drive = Drive.new
    else
      @logged_in = false
    end
  end
  
  def create
    if check_required_params
      start_city = City.findByName(params[:start_address])
      if start_city.nil?
        start_city = City.create({:name => params[:start_address], :latitude => 0, :longitude => 0})
      end
      destination_city = City.findByName(params[:destination_address])
      if destination_city.nil?
        destination_city = City.create({:name => params[:destination_address], :latitude => 0, :longitude => 0})
      end
    
      ddate = build_date_from_params("date",params[:drive])
      drive = Drive.new({:seats => params[:drive][:seats],
                        :free_seats => params[:drive][:seats],
                        :date => ddate,
                        :user_id => current_user.id,
                        :start_city_id => start_city.id,
                        :destination_city_id => destination_city.id
        })
      if drive.save
        flash[:notice] = "Pomyslnie dodano trase."
        add_mid_locations_to_drive(drive)
        redirect_to root_path
      else
        flash[:error] = "Wystapil blad przy dodawaniu trasy" + drive.save!
        render :new
      end
    else
      flash[:error] = "Brak wymaganych pol"
      render :new
    end
  end
  
  def show
    
  end
  
  private
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, 
       params["#{field_name.to_s}(2i)"].to_i, 
       params["#{field_name.to_s}(3i)"].to_i)
  end
  
  def add_mid_locations_to_drive(drive)
    i = 0
    mid_location = params[("through"+i.to_s).to_sym]
    
    until mid_location.blank?
      city = City.findByName(mid_location)
      if city.nil?
        city = City.create({:name => mid_location, :latitude => 0, :longitude => 0})
      end
      
      drive.add_mid_location(city)
      i = i+1
      mid_location = params[("through"+i.to_s).to_sym]
    end
  end
  
  def check_required_params
    cond = true
    if params[:start_address].blank? || params[:destination_address].blank? || params[:drive][:seats].blank?
      cond = false
    end
    cond
  end
end