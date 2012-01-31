 # -*- coding: utf-8 -*-
class DrivesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:create, :edit, :destroy]
  
  def show
    @drive = Drive.find(params[:id])
    @throughs = @drive.mid_locations
    start_add = @drive.start_city.name
    dest_add = @drive.destination_city.name
    throughs_adds = []
    @throughs.each do |through|
      throughs_adds << through.city.name
    end
    
    respond_to do |format|
      format.json do
        render :json => {:start_add => start_add, :destination_add => dest_add, :throughs => throughs_adds}
      end
      format.html do
        render 'show'
      end
    end
  end
  
  def index
    @drives = Drive.paginate :page => params[:page], :per_page => 10
  end
  
  def search
    start_latlon = ActiveSupport::JSON.decode(params[:start_location])
    dest_latlon = ActiveSupport::JSON.decode(params[:dest_location])
    
    start_city = City.findByName(params[:start_address]) || City.findByCoordinates(roundCoordinate(start_latlon['latitude']), roundCoordinate(start_latlon['longitude']))
    dest_city = City.findByName(params[:dest_address]) || City.findByCoordinates(roundCoordinate(dest_latlon['latitude']), roundCoordinate(dest_latlon['longitude']))
    
    @drives = Drive.search(start_city, dest_city)
    
    puts "-------------------------- PARAMS ------------------------"
    puts "start: " + params[:start_address] + ""
    #puts start_city
    puts dest_city.name
  end
  
  def searchSite
    
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
        latlon = ActiveSupport::JSON.decode(params[:startLatLon])
        start_city = City.create({:name => params[:start_address], :latitude => roundCoordinate(latlon['latitude']), 
          :longitude => roundCoordinate(latlon['longitude']) })
      end
      destination_city = City.findByName(params[:destination_address])
      if destination_city.nil?
        latlon = ActiveSupport::JSON.decode(params[:startLatLon])
        destination_city = City.create({:name => params[:destination_address], :latitude => roundCoordinate(latlon['latitude']), 
          :longitude => roundCoordinate(latlon['longitude']) })
      end
    
      #ddate = build_date_from_params("date", params[:drive])
      drive = Drive.new({:seats => params[:drive][:seats],
                        :free_seats => params[:drive][:seats],
                        :date => build_date(params),
                        :user_id => current_user.id,
                        :start_city_id => start_city.id,
                        :destination_city_id => destination_city.id
        })
      if drive.save
        flash[:notice] = "Pomyslnie dodano trase."
        add_mid_locations_to_drive(drive)
        
        respond_to do |format|
          format.json do
            render :json => {:status => "redirect", :path => root_url}
          end
          format.html do
            redirect_to root_path
          end
        end
      else
        flash[:error] = "Wystapil blad przy dodawaniu trasy" + drive.save!
        render :new
      end
    else
      flash[:error] = "Brak wymaganych pol"
      render :new
    end
  end
  
  private
  def build_date_from_params(field_name, params)
    Date.new(params["#{field_name.to_s}(1i)"].to_i, 
       params["#{field_name.to_s}(2i)"].to_i, 
       params["#{field_name.to_s}(3i)"].to_i)
  end
  
  def build_date(params)
    patt = /^(\d\d)-(\d\d)-(\d\d\d\d)$/
    date = nil
    if params[:date] =~ %r{(\d\d)-(\d\d)-(\d\d\d\d)}
      date = Date.new($3.to_i,$2.to_i,$1.to_i)
    end
    date
  end
  
  def add_mid_locations_to_drive(drive)
    i = 0
    mid_location = params[("through"+i.to_s).to_sym]
    
    until mid_location.blank?
      city = City.findByName(mid_location)
      if city.nil?
        latlon = ActiveSupport::JSON.decode(params[:throughsLatLon])['throughsLatLon'][i]

        city = City.create({:name => mid_location, :latitude => latlon['latitude'].to_f.round(3), 
          :longitude => latlon['longitude'].to_f.round(3) })
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
  
  def roundCoordinate(coordinate)
    coordinate.to_f.round(3)
  end
end