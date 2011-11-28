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
    start_city = City.findByName(params[:start_address])
    if start_city==[]
      start_city = City.create({:name => params[:start_address], :latitude => 0, :longitude => 0})
    end
    destination_city = City.findByName(params[:destination_address])
    if destination_city==[]
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
      redirect_to root_path
    else
      puts "date:" + params[:drive][:date]
      flash[:error] = "Wystapil blad przy dodawaniu trasy" + drive.save!
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
end