 # -*- coding: utf-8 -*-
class DrivesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:create, :edit, :destroy, :edit, :destroy]
  
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
      #format.json do
        #render :json => {:start_add => start_add, :destination_add => dest_add, :throughs => throughs_adds}
      #end
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
    
    @drives = Drive.search_up_to_date(start_city, dest_city)

    if @drives
      @drives.collect! do |drive|
        drive = drive.get_info_json
      end
    end
    
    respond_to do |format|
      format.json do
        render :json => @drives
      end
    end
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
  
  def edit
    @drive = Drive.find(params[:id])
    
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
      
      cost_curr = get_cost_and_currency(params)
    
      drive = Drive.new({:seats => params[:drive][:seats],
                        :free_seats => params[:drive][:seats],
                        :date => build_date(params),
                        :user_id => current_user.id,
                        :start_city_id => start_city.id,
                        :destination_city_id => destination_city.id,
                        :comment => params[:comment],
                        :distance => params[:distance],
                        :cost => cost_curr[:cost],
                        :currency => cost_curr[:currency]
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
  
  def destroy
    @drive = Drive.find(params[:id])
    if @drive.user.id == current_user.id
      @drive.destroy
      flash[:notice] = 'Pomyślnie usunięto przejazd.'
    else
      flash[:error] = 'Możesz usuwać tylko swoje przejazdy.'
    end
    redirect_to root_path
  end
  
  private  
  def build_date(params)
    date = nil
    if params[:date] =~ %r{(\d\d)-(\d\d)-(\d\d\d\d)}
      date = Date.new($3.to_i,$2.to_i,$1.to_i)
    end
    date
  end
  
  def get_cost_and_currency(params)
    cost = 0
    currency = 'ns'
    cost = params[:drive][:cost].to_f unless params[:drive][:cost].blank?
    currency = params[:currency] if cost > 0
    {:cost => cost, :currency => currency}
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